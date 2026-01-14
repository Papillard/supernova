class CleanAddressFieldsAndAddServedZones < ActiveRecord::Migration[8.0]
  def change
    # Retirer address de teachers et parent_profiles
    remove_column :teachers, :address, :string
    remove_column :parent_profiles, :address, :string

    # Retirer radius_text de teachers
    remove_column :teachers, :radius_text, :string

    # Ajouter served_zones (array) à teachers
    add_column :teachers, :served_zones, :text, array: true, default: []
  end
end
