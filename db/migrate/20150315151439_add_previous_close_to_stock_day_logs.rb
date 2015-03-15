class AddPreviousCloseToStockDayLogs < ActiveRecord::Migration
  def change
    add_column :stock_day_logs, :previous_close, :decimal, precision: 8, scale: 3
  end
end
