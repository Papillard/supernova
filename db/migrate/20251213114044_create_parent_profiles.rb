class CreateParentProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :parent_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :zip_code
      t.string :city
      t.string :profile_image_url
      t.boolean :profile_completed, default: false, null: false

      t.timestamps
    end
  end
end
