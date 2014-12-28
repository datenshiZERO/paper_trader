class CreateDayTickerLogs < ActiveRecord::Migration
  def change
    create_table :day_ticker_logs do |t|
      t.date :log_at

      t.timestamps null: false
    end
  end
end
