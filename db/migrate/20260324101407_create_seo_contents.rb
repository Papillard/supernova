class CreateSeoContents < ActiveRecord::Migration[8.0]
  def change
    create_table :seo_contents do |t|
      t.references :seo_page, null: false, foreign_key: true
      t.string :block_type, null: false
      t.integer :position, default: 0
      t.text :content, null: false

      t.timestamps
    end

    add_index :seo_contents, [:seo_page_id, :block_type, :position]
  end
end
