class CreatePortfolioTransactions < ActiveRecord::Migration
  def change
    create_table :portfolio_transactions do |t|
      t.references :user, index: true
      t.references :security, index: true
      t.references :stock_ticker_log, index: true
      t.references :portfolio_entry, index: true
      t.decimal :shares
      t.boolean :buy
      t.decimal :fees, precision: 11, scale: 3

      t.timestamps null: false
    end
    add_foreign_key :portfolio_transactions, :users
    add_foreign_key :portfolio_transactions, :securities
    add_foreign_key :portfolio_transactions, :stock_ticker_logs
    add_foreign_key :portfolio_transactions, :portfolio_entries
  end
end
