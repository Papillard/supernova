class CreateSeoPages < ActiveRecord::Migration[8.0]
  def change
    create_table :seo_pages do |t|
      t.references :subject, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.string :slug, null: false
      t.string :page_type, null: false, default: "subject_city"
      t.string :h1, null: false
      t.string :meta_title
      t.text :meta_description
      t.integer :teacher_count, default: 0
      t.boolean :published, default: false

      t.timestamps
    end

    add_index :seo_pages, :slug, unique: true
    add_index :seo_pages, [:subject_id, :city_id], unique: true
  end
end
