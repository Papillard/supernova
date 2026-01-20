class RemovePictureVisibleFromTeachers < ActiveRecord::Migration[8.0]
  def up
    remove_column :teachers, :picture_visible, :boolean
  end

  def down
    add_column :teachers, :picture_visible, :boolean, default: false, null: false
  end
end
