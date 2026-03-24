class CreateSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :subjects do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :tag_code, null: false
      t.string :display_name, null: false
      t.text :description
      t.string :category
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :subjects, :slug, unique: true
    add_index :subjects, :tag_code, unique: true
  end
end
