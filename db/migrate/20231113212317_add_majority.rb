class AddMajority < ActiveRecord::Migration[7.0]
  def change
    add_column :councils, :majority_party, :text
  end
end
