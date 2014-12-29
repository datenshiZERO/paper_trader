class CreateStockDayLogs < ActiveRecord::Migration
  def change
    create_table :stock_day_logs do |t|
      t.references :security, index: true
      t.references :day_ticker_log, index: true
      t.decimal :volume_traded
      t.decimal :open_price, precision: 8, scale: 3
      t.decimal :high_price, precision: 8, scale: 3
      t.decimal :low_price, precision: 8, scale: 3

      t.timestamps null: false
    end
    add_foreign_key :stock_day_logs, :securities
    add_foreign_key :stock_day_logs, :day_ticker_logs
  end
end
