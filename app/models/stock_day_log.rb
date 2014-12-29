class StockDayLog < ActiveRecord::Base
  belongs_to :security
  belongs_to :day_ticker_log
  has_many :stock_ticker_logs
end
