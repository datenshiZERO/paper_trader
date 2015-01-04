class AddCashToUser < ActiveRecord::Migration
  def change
    add_column :users, :cash, :decimal, precision: 14, scale: 2, default: 2000000
  end
end
