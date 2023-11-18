class AddTagTaxonomy < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.text :tag, null: false
      t.text :description, null: true # some might be self-evident!
      t.timestamps
    end

    create_table :meeting_tags do |t|
      t.references :meeting, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
