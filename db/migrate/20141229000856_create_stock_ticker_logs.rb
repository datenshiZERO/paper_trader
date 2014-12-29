class CreateStockTickerLogs < ActiveRecord::Migration
  def change
    create_table :stock_ticker_logs do |t|
      t.references :stock_day_log, index: true
      t.references :ticker_log, index: true
      t.decimal :total_volume
      t.decimal :price, precision: 8, scale: 3

      t.timestamps null: false
    end
    add_foreign_key :stock_ticker_logs, :stock_day_logs
    add_foreign_key :stock_ticker_logs, :ticker_logs
  end
end
