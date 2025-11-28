class Teacher < ApplicationRecord
  belongs_to :user

  # Enums
  enum :gender, { female: "female", male: "male" }
  enum :career_status, {
    certifie: "certifié",
    agrege: "agrégé",
    prof_des_ecoles: "prof des écoles",
    autre: "autre"
  }
  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }
  enum :target_students_range, {
    primaire: "primaire",
    college: "collège",
    lycee: "lycée",
    superieur: "supérieur",
    tous_niveaux: "tous niveaux"
  }

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :display_name, presence: true
  validates :gender, presence: true
  validates :career_status, presence: true
  validates :email_pro, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true
  validates :user_id, uniqueness: true

  # Associations
  has_many :requests, dependent: :destroy

  # Scopes
  scope :approved, -> { where(status: :approved) }
  scope :with_rgpd_consent, -> { where(rgpd_consent: true) }
  scope :public_visible, -> { approved.with_rgpd_consent }

  # Callbacks
  before_validation :set_defaults, on: :create

  private

  def set_defaults
    self.status ||= :pending
    self.rgpd_consent ||= false
    self.profile_image_attached ||= false
    self.levels ||= []
    self.subjects_tags ||= []
    self.teaching_formats ||= []
    self.exam_tags ||= []
    self.pedagogy_tags ||= []
  end
end
