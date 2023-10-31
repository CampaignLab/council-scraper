class AddIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :meetings, :date

    add_column :documents, :text, :text
    add_column :documents, :extract_status, :text, default: 'pending', null: false
  end
end

