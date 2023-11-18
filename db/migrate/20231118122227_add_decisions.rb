class AddDecisions < ActiveRecord::Migration[7.0]
  def change
    create_table :decisions do |t|
      t.references :council, null: false, foreign_key: true
      t.text :url, null: false
      t.text :decision_maker
      t.text :outcome
      t.boolean :is_key, null: false, default: false
      t.boolean :is_callable_in, null: false, default: false

      t.text :purpose
      t.text :content

      t.date :date
      t.timestamps
    end
  end
end
