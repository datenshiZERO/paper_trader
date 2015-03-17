class DayTickerLog < ActiveRecord::Base
  has_many :stock_day_log
  has_many :securities, -> { where("stock_day_logs.volume_traded > 0") }, through: :stock_day_log
  has_many :ticker_logs
end
