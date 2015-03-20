class Security < ActiveRecord::Base
  has_many :stock_day_logs, dependent: :destroy

  def display_class
    if percent_change_close > 0
      "gain"
    elsif percent_change_close < 0
      "loss"
    else
      ""
    end
  end

  def populate_closing_price
    day_logs = self.stock_day_logs.order("created_at desc").all
    last_log = day_logs.first
    if last_log.closing_price.blank?
      last_log.closing_price = previous_close
      last_log.save
    end

    (day_logs.length - 1).times do |i|
      next if day_logs[i + 1].closing_price.present?
      day_logs[i + 1].closing_price = day_logs[i].closing_price
      day_logs[i + 1].open_price = day_logs[i].closing_price
      day_logs[i + 1].high_price = day_logs[i].closing_price
      day_logs[i + 1].low_price = day_logs[i].closing_price
      day_logs[i + 1].save
    end
  end

  def populate_technicals
    populate_closing_price

    day_logs = self.stock_day_logs.order(:created_at).all
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
      if i == 33
        day_logs[33].macd_signal = (day_logs[25..33].sum(&:macd) / 9).round(3)
        day_logs[33].macd_divergence = day_logs[33].macd - day_logs[33].macd_signal 
      end
      if i > 33
        day_logs[i].macd_signal = (day_logs[i].macd * (2.0/10.0) + day_logs[i - 1].macd_signal * (1 - (2.0/10.0))).round(3)
        day_logs[i].macd_divergence = day_logs[i].macd - day_logs[i].macd_signal 
      end
      day_logs[i].save
    end
  end

  def calculate_day_technicals
    day_logs = self.stock_day_logs.order(:created_at).all

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
      day_logs[33].macd_signal = (day_logs[25..33].sum(&:macd) / 9).round(3)
      day_logs[33].macd_divergence = day_logs[33].macd - day_logs[33].macd_signal 
    end
    if day_logs.length > 34
      day_logs[-1].macd_signal = (day_logs[-1].macd * (2.0/10.0) + day_logs[-2].macd_signal * (1.0 - (2.0/10.0))).round(3)
      day_logs[-1].macd_divergence = day_logs[-1].macd - day_logs[-1].macd_signal 
    end
    day_logs[-1].save
  end
end
