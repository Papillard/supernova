class Message < ApplicationRecord
  belongs_to :request
  belongs_to :user

  # Validations
  validates :body, presence: true

  # Callbacks
  after_create :update_request_last_message_at
  after_create_commit :notify_new_message

  private

  def update_request_last_message_at
    request.update_column(:last_message_at, Time.current)
  end

  def notify_new_message
    return if system?

    Notifications::MessageNotifier.call(self)
  end
end
