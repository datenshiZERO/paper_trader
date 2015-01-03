class Security < ActiveRecord::Base
  has_many :stock_day_logs

  def display_class
    if percent_change_close > 0
      "gain"
    elsif percent_change_close < 0
      "loss"
    else
      ""
    end
  end
end
