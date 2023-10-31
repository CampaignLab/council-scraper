class Initial < ActiveRecord::Migration[7.0]
  def change
    create_table :councils do |t|
      t.text :name
      t.text :external_id
      t.text :base_scrape_url

      t.timestamps
    end

    create_table :committees do |t|
      t.references :council, null: false, foreign_key: true
      t.text :name
      t.text :url

      t.timestamps
    end

    create_table :people do |t|
      t.references :council, null: false, foreign_key: true
      t.text :name
      t.text :role

      t.timestamps
    end

    create_table :meetings do |t|
      t.references :council, null: false, foreign_key: true
      t.references :committee, foreign_key: true
      t.text :name
      t.text :url
      t.text :notes
      t.datetime :date

      t.timestamps
    end

    create_table :documents do |t|
      t.references :meeting, null: false, foreign_key: true
      t.text :name
      t.text :url

      t.timestamps
    end
  end
end
