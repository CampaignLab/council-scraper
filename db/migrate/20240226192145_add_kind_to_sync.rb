class AddKindToSync < ActiveRecord::Migration[7.0]
  def change
    add_column :council_syncs, :kind, :string, default: 'scrape', null: false
  end
end
