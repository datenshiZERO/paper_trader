class DayTickerLog < ActiveRecord::Base
  has_many :stock_day_log
  has_many :securities, -> { where("stock_day_logs.volume_traded > 0") }, through: :stock_day_log
  has_many :ticker_logs

  def fix_non_moving
    stock_day_logs.each do |s|
      if s.volume_traded == 0
        s.open_price = s.previous_close
        s.high_price = s.previous_close
        s.low_price = s.previous_close
        s.closing_price = s.previous_close
        s.save
      end
    end
  end
end
