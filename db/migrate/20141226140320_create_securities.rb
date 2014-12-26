class CreateSecurities < ActiveRecord::Migration
  def change
    create_table :securities do |t|
      t.string :symbol
      t.string :company_name
      t.text :company_profile
      t.integer :board_lot
      t.decimal :last_price, precision: 8, scale: 3
      t.decimal :volume_traded
      t.decimal :open_price, precision: 8, scale: 3
      t.decimal :high_price, precision: 8, scale: 3
      t.decimal :low_price, precision: 8, scale: 3
      t.decimal :previous_close, precision: 8, scale: 3
      t.float :percent_change_close

      t.timestamps null: false
    end
  end
end
