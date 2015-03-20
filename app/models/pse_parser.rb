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
        s.volume_traded = 0
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
      s.populate_technicals
    end
  end

  def self.calculate_day_technicals
    DayTickerLog.last.fix_non_moving
    Security.all.each do |s|
      #begin 
        s.calculate_day_technicals
      #rescue
        #s.populate_technicals
      #end
    end
  end
end
