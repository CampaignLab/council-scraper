class ModifyClassificationOutput < ActiveRecord::Migration[7.0]
  def up
    change_column :document_classifications, :output, :jsonb, using: 'output::jsonb'
    add_column :document_classifications, :model, :text, null: false
  end

  def down
    change_column :document_classifications, :output, :text, using: 'output::text'
    remove_column :document_classifications, :model
  end
end
