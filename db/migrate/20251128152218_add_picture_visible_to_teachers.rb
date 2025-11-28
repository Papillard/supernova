class AddPictureVisibleToTeachers < ActiveRecord::Migration[8.0]
  def change
    add_column :teachers, :picture_visible, :boolean, null: false, default: false
  end
end
