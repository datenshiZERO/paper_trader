class PseParser
  TICKER_URL = "http://www.pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true"
  NOT_STOCK = ["Stock Update As of", "PSE", "ALL", "FIN", "IND", "HDG", "PRO", "SVC", "M-O"]

  def parse_ticker
    ticker = get_json
    ticker_time = DateTime.strptime(ticker.first['securityAlias'], "%m/%d/%Y %I:%M %p")

    return if TickerLog.exists?(ticker_as_of: ticker_time)

    day_ticker_log = get_or_generate_day_log(ticker_time)

    TickerLog.create(
      ticker_as_of: ticker_time,
      ticker_json: ticker.to_s,
      day_ticker_log: day_ticker_log
    )

    stock_hash = get_stock_hash

    ticker.each do |s|
      next if NOT_STOCK.include? s['securitySymbol']
      unless stock_hash.has_key? s['securitySymbol']
        new_stock = Security.create(
          symbol: s['securitySymbol'],
          company_name: s['securityAlias']
        )
        stock_hash[new_stock.symbol] = new_stock
      end
    end
  end

  def get_json
    JSON.load(Typhoeus.get(TICKER_URL).body)
  end

  def get_or_generate_day_log(ticker_time)
    ticker_day = Date.new(ticker_time.year, ticker_time.month, ticker_time.day)
    if DayTickerLog.exists?(log_at: ticker_day)
      DayTickerLog.where(log_at: ticker_time).first
    else
      DayTickerLog.create(log_at: ticker_day)
    end
  end

  def get_stock_hash
    Security.all.reduce({}) do |h, s|
      h[s.symbol] = s
      h
    end
  end

end
