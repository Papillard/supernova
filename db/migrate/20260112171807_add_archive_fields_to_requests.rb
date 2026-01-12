class AddArchiveFieldsToRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :requests, :archived_by_parent, :boolean, default: false, null: false
    add_column :requests, :archived_by_teacher, :boolean, default: false, null: false
  end
end
