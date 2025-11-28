class CreateRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :requests do |t|
      t.references :parent, null: false, foreign_key: { to_table: :users }
      t.references :teacher, null: false, foreign_key: { to_table: :teachers }
      t.string :status, null: false, default: "pending"
      t.string :subject, null: false
      t.string :level, null: false
      t.string :request_text, null: false
      t.datetime :requested_at, null: false
      t.datetime :responded_at
      t.datetime :last_message_at

      t.timestamps
    end
  end
end
