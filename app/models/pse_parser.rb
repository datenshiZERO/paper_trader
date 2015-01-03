class PseParser
  TICKER_URL = "http://www.pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true"
  NOT_STOCK = ["Stock Update As of", "PSE", "ALL", "FIN", "IND", "HDG", "PRO", "SVC", "M-O"]

  def parse_ticker
    ticker = get_json
    ticker_time = DateTime.strptime(ticker.first['securityAlias'] + " +0800", "%m/%d/%Y %I:%M %p %z")

    return if TickerLog.exists?(ticker_as_of: ticker_time)

    stock_hash = get_stock_hash
    day_ticker_log = get_or_generate_day_log(ticker_time, stock_hash)

    ticker_log = TickerLog.create(
      ticker_as_of: ticker_time,
      ticker_json: ticker.to_s,
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
        StockDayLog.create security: s, day_ticker_log: day_log
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

end
