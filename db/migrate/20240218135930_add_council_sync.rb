class AddCouncilSync < ActiveRecord::Migration[7.0]
  def change
    create_table :council_syncs do |t|
      t.references :council, null: false, foreign_key: true
      t.date :week, null: false
      t.string :status, null: false, default: 'waiting'
      t.datetime :last_synced_at

      t.timestamps
    end
  end
end
