class AddMediaDocument < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :is_media, :boolean, default: false, null: false
  end
end
