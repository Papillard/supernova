class AddGinIndexesToTeachers < ActiveRecord::Migration[8.0]
  def change
    add_index :teachers, :served_zones, using: :gin, if_not_exists: true
    add_index :teachers, :subjects_tags, using: :gin, if_not_exists: true
  end
end
