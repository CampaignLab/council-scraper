class AddTopline < ActiveRecord::Migration[7.0]
  def change
    add_column :meetings, :topline, :text
  end
end
