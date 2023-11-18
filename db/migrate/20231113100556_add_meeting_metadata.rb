class AddMeetingMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :meetings, :agenda, :text, null: true
    add_column :meetings, :about, :text, null: true
    add_column :meetings, :additional_attendees, :jsonb, null: false, default: []
    add_column :documents, :kind, :text, null: false, default: 'unclassified'

    create_table :person_meetings do |t|
      t.references :meeting, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true

      t.timestamps
    end
  end
end
