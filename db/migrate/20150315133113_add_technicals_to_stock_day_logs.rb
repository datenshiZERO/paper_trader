class AddTechnicalsToStockDayLogs < ActiveRecord::Migration
  def change
    add_column :stock_day_logs, :ema_12, :decimal, precision: 8, scale: 3
    add_column :stock_day_logs, :ema_14_up, :decimal, precision: 8, scale: 3
    add_column :stock_day_logs, :ema_14_down, :decimal, precision: 8, scale: 3
    add_column :stock_day_logs, :ema_26, :decimal, precision: 8, scale: 3
    add_column :stock_day_logs, :ema_30, :decimal, precision: 8, scale: 3
    add_column :stock_day_logs, :sma_10, :decimal, precision: 8, scale: 3
    add_column :stock_day_logs, :rsi, :decimal, precision: 8, scale: 3
    add_column :stock_day_logs, :macd_signal, :decimal, precision: 8, scale: 3
    add_column :stock_day_logs, :macd_divergence, :decimal, precision: 8, scale: 3
  end
end
