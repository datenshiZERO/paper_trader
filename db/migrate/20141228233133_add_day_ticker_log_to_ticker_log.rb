class AddDayTickerLogToTickerLog < ActiveRecord::Migration
  def change
    add_column :ticker_logs, :day_ticker_log_id, :integer
    add_index :ticker_logs, :day_ticker_log_id
  end
end
