class AddCascadeDeleteToEmailEventsRequests < ActiveRecord::Migration[8.0]
  def up
    # Supprimer la clé étrangère existante
    remove_foreign_key :email_events, :requests if foreign_key_exists?(:email_events, :requests)

    # Recréer avec on_delete: :cascade
    add_foreign_key :email_events, :requests, column: :request_id, on_delete: :cascade
  end

  def down
    # Supprimer la clé étrangère avec cascade
    remove_foreign_key :email_events, :requests if foreign_key_exists?(:email_events, :requests)

    # Recréer sans cascade (comportement par défaut)
    add_foreign_key :email_events, :requests, column: :request_id
  end
end
