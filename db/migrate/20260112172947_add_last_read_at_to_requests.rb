class AddLastReadAtToRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :requests, :parent_last_read_at, :datetime
    add_column :requests, :teacher_last_read_at, :datetime
  end
end
