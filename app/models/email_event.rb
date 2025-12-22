class EmailEvent < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :request, optional: true

  validates :kind, presence: true
  validates :recipient_id, presence: true
  validates :sent_at, presence: true
end
