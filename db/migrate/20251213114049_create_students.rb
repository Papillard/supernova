class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.references :parent_profile, null: false, foreign_key: true
      t.string :first_name
      t.integer :birth_year

      t.timestamps
    end
  end
end
