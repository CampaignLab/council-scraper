class DocumentClassifications < ActiveRecord::Migration[7.0]
  def change
    create_table :document_classifications do |t|
      t.references :document, null: false, foreign_key: true
      t.text :input
      t.text :output
      t.jsonb :classifications
      t.integer :input_token_count
      t.integer :output_token_count
      t.integer :cost
      
      t.timestamps
    end
  end
end
