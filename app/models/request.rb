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
  # notes et request_text sont optionnels - le message initial sera généré automatiquement

  # Callbacks
  before_validation :set_requested_at, on: :create
  after_create :set_initial_last_message_at
  after_create_commit :notify_request_created
  after_update_commit :notify_status_change

  # Scopes
  scope :recent, -> { order(last_message_at: :desc) }
  scope :not_archived_by_parent, -> { where(archived_by_parent: false) }
  scope :not_archived_by_teacher, -> { where(archived_by_teacher: false) }
  scope :visible_to_parent, -> { not_archived_by_parent }
  scope :visible_to_teacher, -> { not_archived_by_teacher }

  # Scopes pour notifications non lues
  # Parent: messages non lus sur pending OU changement de statut (accepted/declined) non vu
  scope :unread_for_parent, -> {
    visible_to_parent.where(
      "(status = 'pending' AND last_message_at > COALESCE(parent_last_read_at, '1970-01-01')) OR " \
      "(status IN ('accepted', 'declined') AND responded_at > COALESCE(parent_last_read_at, '1970-01-01'))"
    )
  }
  # Teacher: uniquement messages non lus sur pending
  scope :unread_for_teacher, -> {
    pending.visible_to_teacher.where("last_message_at > COALESCE(teacher_last_read_at, '1970-01-01')")
  }

  # Marquer comme lu
  def mark_as_read_by_parent!
    update_column(:parent_last_read_at, Time.current)
  end

  def mark_as_read_by_teacher!
    update_column(:teacher_last_read_at, Time.current)
  end

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
