class CreatePortfolioEntries < ActiveRecord::Migration
  def change
    create_table :portfolio_entries do |t|
      t.references :user, index: true
      t.references :security, index: true
      t.decimal :shares

      t.timestamps null: false
    end
    add_foreign_key :portfolio_entries, :users
    add_foreign_key :portfolio_entries, :securities
  end
end
