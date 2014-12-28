class CreateTickerLogs < ActiveRecord::Migration
  def change
    create_table :ticker_logs do |t|
      t.timestamp :ticker_as_of
      t.text :ticker_json

      t.timestamps null: false
    end

    add_index :ticker_logs, :ticker_as_of, unique: true
  end
end
