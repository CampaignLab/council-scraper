class AddDecisionClassifications < ActiveRecord::Migration[7.0]
  def change
    create_table 'decision_classifications', force: :cascade do |t|
      t.references :decision, null: false, foreign_key: true
      t.text 'input'
      t.jsonb 'output'
      t.jsonb 'classifications'
      t.integer 'input_token_count'
      t.integer 'output_token_count'
      t.integer 'cost'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.text 'model', null: false
    end
  end
end
