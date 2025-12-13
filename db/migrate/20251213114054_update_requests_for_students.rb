class UpdateRequestsForStudents < ActiveRecord::Migration[8.0]
  def change
    add_reference :requests, :student, null: true, foreign_key: true
    add_column :requests, :notes, :text

    # Note: subject and level already exist in the requests table
    # request_text will remain for backward compatibility, but notes is the new field
  end
end
