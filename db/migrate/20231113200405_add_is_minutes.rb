class AddIsMinutes < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :is_minutes, :boolean, default: false, null: false
  end
end
