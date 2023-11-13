class AddPersonCols < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :modern_gov_id, :integer
    add_column :people, :ocd_id, :integer
    add_column :committees, :modern_gov_id, :integer
    add_column :people, :party, :text
    add_column :people, :is_councillor, :boolean, default: false, null: false
  end
end
