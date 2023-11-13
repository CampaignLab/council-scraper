class AddMoreClassifications < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :contains_agenda, :boolean, default: false, null: false
    add_column :documents, :contains_attendees, :boolean, default: false, null: false
    add_column :documents, :contains_decisions, :boolean, default: false, null: false
    add_column :meetings, :decisions, :jsonb, null: false, default: []
  end
end
