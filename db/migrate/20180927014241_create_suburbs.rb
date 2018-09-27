class CreateSuburbs < ActiveRecord::Migration[5.1]
  def change
    create_table :suburbs do |t|
      t.text :name
      t.text :town_city
      t.references :region
      t.timestamps null: false
    end

    create_table :regions do |t|
      t.text :name
      t.timestamps
    end

    add_column :homes, :suburb_id, :int
    add_foreign_key :homes, :suburbs
    add_foreign_key :suburbs, :regions
  end
end
