class AddClosingPriceToStockDayLogs < ActiveRecord::Migration
  def change
    add_column :stock_day_logs, :closing_price, :decimal, precision: 8, scale: 3
  end
end
