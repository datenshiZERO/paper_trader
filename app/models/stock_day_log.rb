class StockDayLog < ActiveRecord::Base
  belongs_to :security
  belongs_to :day_ticker_log
  has_many :stock_ticker_logs

  def upward_change
    if closing_price > previous_close
      closing_price - previous_close
    else
      0.0
    end
  end

  def downward_change
    if previous_close > closing_price
      previous_close - closing_price
    else
      0.0
    end
  end

  def macd
    return nil if ema_12.nil? || ema_26.nil?
    ema_12 - ema_26
  end
end
