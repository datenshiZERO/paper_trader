class PseParser
  TICKER_URL = "http://www.pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true"
  def get_json
    JSON.load(Typhoeus.get(TICKER_URL).body)
  end
end
