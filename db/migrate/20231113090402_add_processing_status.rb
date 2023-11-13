class AddProcessingStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :processing_status, :text, null: false, default: 'waiting'
  end
end
