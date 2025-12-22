class Request < ApplicationRecord
  belongs_to :parent, class_name: "User"
  belongs_to :teacher
  belongs_to :student
  has_many :messages, dependent: :destroy

  # Enum for status
  enum :status, { pending: "pending", accepted: "accepted", declined: "declined" }

  # Validations
  validates :subject, presence: { message: "La matière est requise" }
  validates :level, presence: { message: "Le niveau est requis" }
  validates :requested_at, presence: true
  validates :student, presence: { message: "L'enfant est requis" }
  # notes est optionnel - pas de validation de présence

  # Validation personnalisée : au moins request_text ou notes doit être présent
  validate :request_text_or_notes_present

  def request_text_or_notes_present
    if request_text.blank? && notes.blank?
      errors.add(:base, "Veuillez préciser votre demande pour le professeur")
    end
  end

  # Callbacks
  before_validation :set_requested_at, on: :create
  after_create :set_initial_last_message_at
  after_create_commit :notify_request_created
  after_update_commit :notify_status_change

  # Scopes
  scope :recent, -> { order(last_message_at: :desc) }

  private

  def set_requested_at
    self.requested_at ||= Time.current
  end

  def set_initial_last_message_at
    update_column(:last_message_at, Time.current)
  end

  def notify_request_created
    Notifications::RequestNotifier.call(self, event: :created)
  end

  def notify_status_change
    return unless saved_change_to_status?

    previous_status = saved_change_to_status[0]
    current_status = saved_change_to_status[1]

    if previous_status == "pending" && current_status == "accepted"
      # Mettre à jour responded_at si pas déjà fait (le contrôleur le fait normalement)
      update_column(:responded_at, Time.current) if responded_at.nil?
      Notifications::RequestNotifier.call(self, event: :accepted)
    elsif previous_status == "pending" && current_status == "declined"
      # Mettre à jour responded_at si pas déjà fait (le contrôleur le fait normalement)
      update_column(:responded_at, Time.current) if responded_at.nil?
      Notifications::RequestNotifier.call(self, event: :declined)
    end
  end
end
