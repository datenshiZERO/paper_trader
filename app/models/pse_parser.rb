class PseParser
  TICKER_URL = "http://www.pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true"
  NOT_STOCK = ["Stock Update As of", "PSE", "ALL", "FIN", "IND", "HDG", "PRO", "SVC", "M-O"]

  def parse_ticker
    begin
      perform_parsing
    rescue => e
      ParsingErrorLog.create(error_message: e.message, error_text: e.backtrace)
    end
  end

  def perform_parsing
    ticker = get_json
    return if ticker.length == 0
    ticker_time = DateTime.strptime(ticker.first['securityAlias'] + " +0800", "%m/%d/%Y %I:%M %p %z")

    return if TickerLog.exists?(ticker_as_of: ticker_time)

    stock_hash = get_stock_hash
    day_ticker_log = get_or_generate_day_log(ticker_time, stock_hash)

    ticker_log = TickerLog.create(
      ticker_as_of: ticker_time,
      #ticker_json: ticker.to_s,
      day_ticker_log: day_ticker_log
    )

    ticker.each do |s|
      next if NOT_STOCK.include? s['securitySymbol']
      unless stock_hash.has_key? s['securitySymbol']
        new_stock = Security.create(
          symbol: s['securitySymbol'],
          company_name: s['securityAlias']
        )
        StockDayLog.create security: new_stock, day_ticker_log: day_ticker_log
        stock_hash[new_stock.symbol] = new_stock
      end

      stock = stock_hash[s['securitySymbol']]
      stock_day_log = stock.stock_day_logs.where(day_ticker_log: day_ticker_log).first
      total_volume = BigDecimal.new(s['totalVolume'].gsub(",", ""))
      price = BigDecimal.new(s['lastTradedPrice'].gsub(",", ""))

      StockTickerLog.create(
        stock_day_log: stock_day_log,
        ticker_log: ticker_log,
        total_volume: total_volume,
        price: price
      )

      stock.last_price = price
      stock_day_log.closing_price = price

      stock_day_log.volume_traded = total_volume
      stock.volume_traded = total_volume

      if stock_day_log.open_price.nil?
        stock_day_log.open_price = price 
        stock.open_price = price 
      end
      if stock_day_log.low_price.nil? or price < stock_day_log.low_price 
        stock_day_log.low_price = price
        stock.low_price = price
      end
      if stock_day_log.high_price.nil? or price > stock_day_log.high_price 
        stock_day_log.high_price = price
        stock.high_price = price
      end
      stock_day_log.save
      stock.percent_change_close = s['percChangeClose'].to_f
      stock.save
    end
  end

  def get_json
    JSON.load(Typhoeus.get(TICKER_URL).body)
  end

  def get_or_generate_day_log(ticker_time, stock_hash)
    ticker_day = Date.new(ticker_time.year, ticker_time.month, ticker_time.day)
    if DayTickerLog.exists?(log_at: ticker_day)
      DayTickerLog.where(log_at: ticker_time).first
    else
      day_log = DayTickerLog.create(log_at: ticker_day)
      stock_hash.each_value do |s|
        StockDayLog.create security: s, day_ticker_log: day_log, previous_close: s.last_price
        s.previous_close = s.last_price
        s.save
      end
      day_log
    end
  end

  def get_stock_hash
    Security.all.reduce({}) do |h, s|
      h[s.symbol] = s
      h
    end
  end

  def self.fix_closing
    Security.all.each do |s|
      day_logs = s.stock_day_logs.order(:created_at).all
      (day_logs.length - 1).times do |i|
        next_price = day_logs[i + 1].open_price
        unless next_price == nil
          if day_logs[i].high_price.nil? || day_logs[i].low_price.nil?
            next_price = nil
          elsif next_price > day_logs[i].high_price
            next_price = day_logs[i].high_price
          elsif next_price < day_logs[i].low_price
            next_price = day_logs[i].low_price
          end
        end
        day_logs[i].closing_price = next_price
        day_logs[i].save
      end
      day_logs[-1].closing_price = s.last_price
      day_logs[-1].save
    end
  end

  def self.fix_closing_2
    Security.all.each do |s|
      day_logs = s.stock_day_logs.order('created_at desc').all
      current = s.last_price
      (day_logs.length).times do |i|
        if day_logs[i].volume_traded == 0 || day_logs[i].volume_traded.nil?
          day_logs[i].open_price = current
          day_logs[i].high_price = current
          day_logs[i].low_price = current
          day_logs[i].closing_price = current
          day_logs[i].volume_traded = 0
          day_logs[i].save
        elsif day_logs[i].closing_price == 0 || day_logs[i].closing_price.nil?
          day_logs[i].closing_price = current
          if day_logs[i].closing_price < day_logs[i].low_price
            day_logs[i].closing_price = day_logs[i].low_price
          elsif day_logs[i].closing_price > day_logs[i].high_price
            day_logs[i].closing_price = day_logs[i].high_price
          end
          day_logs[i].save
          current = day_logs[i].open_price
        else
          current = day_logs[i].open_price
        end
      end
    end
  end

  def self.populate_previous_close
    Security.all.each do |s|
      day_logs = s.stock_day_logs.order(:created_at).all
      (day_logs.length - 1).times do |i|
        day_logs[i + 1].previous_close = day_logs[i].closing_price
        day_logs[i + 1].save
      end
    end
  end

  def self.populate_technicals
    Security.all.each do |s|
      day_logs = s.stock_day_logs.order(:created_at).all
      (day_logs.length - 9).times do |i|
        day_logs[9 + i].sma_10 = (day_logs[(0 + i)..(9 + i)].sum(&:closing_price) / 10).round(3)
      end
      if day_logs.length >= 12
        day_logs[11].ema_12 = (day_logs[0..11].sum(&:closing_price) / 12).round(3)
      end
      if day_logs.length >= 15
        day_logs[14].ema_14_up = (day_logs[1..14].sum(&:upward_change) / 14).round(3)
        day_logs[14].ema_14_down = (day_logs[1..14].sum(&:downward_change) / 14).round(3)
      end
      if day_logs.length >= 26
        day_logs[25].ema_26 = (day_logs[0..25].sum(&:closing_price) / 26).round(3)
      end
      if day_logs.length >= 30
        day_logs[29].ema_30 = (day_logs[0..29].sum(&:closing_price) / 30).round(3)
      end

      (9..(day_logs.length - 1)).each do |i|
        if i > 11
          day_logs[i].ema_12 = (day_logs[i].closing_price * (2.0/13.0) + day_logs[i - 1].ema_12 * (1 - (2.0/13.0))).round(3)
        end
        if i > 14
          day_logs[i].ema_14_up = (day_logs[i].upward_change * (2.0/15.0) + day_logs[i - 1].ema_14_up * (1.0 - (2.0/15.0))).round(3)
          day_logs[i].ema_14_down = (day_logs[i].downward_change * (2.0/15.0) + day_logs[i - 1].ema_14_down * (1.0 - (2.0/15.0))).round(3)

          if day_logs[i].ema_14_down < 0.001
            if day_logs[i].ema_14_up < 0.001 
              day_logs[i].rsi = 50.0
            else
              day_logs[i].rsi = 100.0
            end
          else
            day_logs[i].rsi = (100.0 - (100.0/(1.0+(day_logs[i].ema_14_up / day_logs[i].ema_14_down)))).round(3)
          end
        end
        if i > 25
          day_logs[i].ema_26 = (day_logs[i].closing_price * (2.0/27.0) + day_logs[i - 1].ema_26 * (1 - (2.0/27.0))).round(3)
        end
        if i > 29
          day_logs[i].ema_30 = (day_logs[i].closing_price * (2.0/31.0) + day_logs[i - 1].ema_30 * (1 - (2.0/31.0))).round(3)
        end
        if i == 34
          day_logs[34].macd_signal = (day_logs[25..34].sum(&:macd) / 9).round(3)
          day_logs[34].macd_divergence = day_logs[34].macd - day_logs[34].macd_signal 
        end
        if i > 34
          day_logs[i].macd_signal = (day_logs[i].macd * (2.0/10.0) + day_logs[i - 1].macd_signal * (1 - (2.0/10.0))).round(3)
          day_logs[i].macd_divergence = day_logs[i].macd - day_logs[i].macd_signal 
        end
        day_logs[i].save
      end
    end
  end

  def self.calculate_day_technicals
    Security.all.each do |s|
      last_log = s.stock_day_logs.order("created_at desc").first
      if last_log.previous_close.nil?
        previous_log = s.stock_day_logs.order("created_at desc").offset(1).first
        if previous_log.present?
          last_log.previous_close = previous_log.closing_price
        end
      end
      if last_log.closing_price.nil?
        last_log.closing_price = s.last_price
      end
      if last_log.open_price.nil?
        last_log.open_price = s.last_price
      end
      if last_log.high_price.nil?
        last_log.high_price = [last_log.closing_price, last_log.open_price].max
      end
      if last_log.low_price.nil?
        last_log.low_price = [last_log.closing_price, last_log.open_price].min
      end
      if last_log.volume_traded.nil?
        last_log.volume_traded = 0
      end
      last_log.save

      day_logs = s.stock_day_logs.order(:created_at).all

      if day_logs.length >= 10
        day_logs[-1].sma_10 = (day_logs[-10..-1].sum(&:closing_price) / 10).round(3)
      end

      if day_logs.length == 12
        day_logs[11].ema_12 = (day_logs[0..11].sum(&:closing_price) / 12).round(3)
      end
      if day_logs.length > 12
        day_logs[-1].ema_12 = (day_logs[-1].closing_price * (2.0/13.0) + day_logs[-2].ema_12 * (1.0 - (2.0/13.0))).round(3)
      end

      if day_logs.length == 15
        day_logs[14].ema_14_up = (day_logs[1..14].sum(&:upward_change) / 14).round(3)
        day_logs[14].ema_14_down = (day_logs[1..14].sum(&:downward_change) / 14).round(3)
      end

      if day_logs.length > 15
        day_logs[-1].ema_14_up = (day_logs[-1].upward_change * (2.0/15.0) + day_logs[-2].ema_14_up * (1.0 - (2.0/15.0))).round(3)
        day_logs[-1].ema_14_down = (day_logs[-1].downward_change * (2.0/15.0) + day_logs[-2].ema_14_down * (1.0 - (2.0/15.0))).round(3)

        if day_logs[-1].ema_14_down < 0.001
          if day_logs[-1].ema_14_up < 0.001 
            day_logs[-1].rsi = 50.0
          else
            day_logs[-1].rsi = 100.0
          end
        else
          day_logs[-1].rsi = (100.0 - (100.0/(1.0+(day_logs[-1].ema_14_up / day_logs[-1].ema_14_down)))).round(3)
        end
      end

      if day_logs.length == 26
        day_logs[25].ema_26 = (day_logs[0..25].sum(&:closing_price) / 26).round(3)
      end

      if day_logs.length > 26
        day_logs[-1].ema_26 = (day_logs[-1].closing_price * (2.0/27.0) + day_logs[-2].ema_26 * (1.0 - (2.0/27.0))).round(3)
      end

      if day_logs.length == 30
        day_logs[29].ema_30 = (day_logs[0..29].sum(&:closing_price) / 30).round(3)
      end
      if day_logs.length > 30
        day_logs[-1].ema_30 = (day_logs[-1].closing_price * (2.0/31.0) + day_logs[-2].ema_30 * (1.0 - (2.0/31.0))).round(3)
      end

      if day_logs.length == 34
        day_logs[34].macd_signal = (day_logs[25..34].sum(&:macd) / 9).round(3)
        day_logs[34].macd_divergence = day_logs[34].macd - day_logs[34].macd_signal 
      end
      if day_logs.length > 34
        day_logs[-1].macd_signal = (day_logs[-1].macd * (2.0/10.0) + day_logs[-2].macd_signal * (1.0 - (2.0/10.0))).round(3)
        day_logs[-1].macd_divergence = day_logs[-1].macd - day_logs[-1].macd_signal 
      end
      day_logs[-1].save
    end
  end
end
