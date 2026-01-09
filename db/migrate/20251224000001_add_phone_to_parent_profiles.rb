class AddPhoneToParentProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :parent_profiles, :phone, :string
  end
end
