class CreateParsingErrorLogs < ActiveRecord::Migration
  def change
    create_table :parsing_error_logs do |t|
      t.string :error_message
      t.text :error_text

      t.timestamps null: false
    end
  end
end
