class CreateEmailEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :email_events do |t|
      t.string :kind, null: false
      t.bigint :request_id
      t.bigint :recipient_id, null: false
      t.datetime :sent_at, null: false

      t.timestamps
    end

    add_index :email_events, [:kind, :request_id, :recipient_id, :sent_at], name: "index_email_events_on_kind_request_recipient_sent_at"
    add_foreign_key :email_events, :users, column: :recipient_id
    add_foreign_key :email_events, :requests, column: :request_id
  end
end
