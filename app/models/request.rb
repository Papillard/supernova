class Request < ApplicationRecord
  belongs_to :parent, class_name: "User"
  belongs_to :teacher
  has_many :messages, dependent: :destroy

  # Enum for status
  enum :status, { pending: "pending", accepted: "accepted", declined: "declined" }

  # Validations
  validates :subject, presence: true
  validates :level, presence: true
  validates :request_text, presence: true
  validates :requested_at, presence: true

  # Callbacks
  before_validation :set_requested_at, on: :create
  after_create :set_initial_last_message_at

  # Scopes
  scope :recent, -> { order(last_message_at: :desc) }

  private

  def set_requested_at
    self.requested_at ||= Time.current
  end

  def set_initial_last_message_at
    update_column(:last_message_at, Time.current)
  end
end
