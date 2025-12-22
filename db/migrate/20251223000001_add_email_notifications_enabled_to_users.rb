class AddEmailNotificationsEnabledToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_notifications_enabled, :boolean, default: true, null: false
  end
end
