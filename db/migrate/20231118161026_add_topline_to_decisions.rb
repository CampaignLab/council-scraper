class AddToplineToDecisions < ActiveRecord::Migration[7.0]
  def change
    add_column :decisions, :topline, :text
  end
end
