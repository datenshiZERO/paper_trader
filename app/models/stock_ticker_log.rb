class StockTickerLog < ActiveRecord::Base
  belongs_to :stock_day_log
  belongs_to :ticker_log
end
