class CreateCities < ActiveRecord::Migration[8.0]
  def change
    create_table :cities do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :department_code, null: false
      t.text :served_zone_codes, array: true, default: []
      t.integer :population_tier, default: 1
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :parent_city

      t.timestamps
    end

    add_index :cities, :slug, unique: true
    add_index :cities, :department_code
  end
end
