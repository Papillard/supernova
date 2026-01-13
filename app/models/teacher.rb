class Teacher < ApplicationRecord
  belongs_to :user

  # Enums
  enum :gender, { female: "female", male: "male", other: "other" }
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
  validates :gender, presence: true
  validates :career_status, presence: true
  validates :email_pro, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :status, presence: true
  validates :user_id, uniqueness: true

  # Associations
  has_many :requests, dependent: :destroy
  has_many_attached :verification_documents

  # Scopes
  scope :approved, -> { where(status: :approved) }
  scope :with_rgpd_consent, -> { where(rgpd_consent: true) }
  scope :public_visible, -> { approved.with_rgpd_consent }

  # Vérifie si le profil est suffisamment complété pour accéder aux demandes
  # Critères minimum:
  # - Identité: display_name présent
  # - Offre: subjects_tags et levels non vides
  # - Logistique: teaching_formats non vide + city ou zip_code renseigné
  # - Confiance: rgpd_consent = true
  def profile_completed?
    display_name.present? &&
      subjects_tags.present? &&
      levels.present? &&
      teaching_formats.present? &&
      (city.present? || zip_code.present?) &&
      rgpd_consent == true
  end

  # Méthode pour obtenir la valeur formatée du career_status
  def formatted_career_status
    return "" if career_status.blank?

    # L'enum retourne la valeur stockée dans la DB
    # Si c'est la valeur avec accent, on la capitalise
    # Si c'est la clé sans accent, on la convertit
    case career_status.to_s
    when "certifié", "certifie"
      "Certifié"
    when "agrégé", "agrege"
      "Agrégé"
    when "prof des écoles", "prof_des_ecoles"
      "Prof des écoles"
    when "autre"
      "Autre"
    else
      career_status.to_s.capitalize
    end
  end

  # Callbacks
  before_validation :set_defaults, on: :create
  before_validation :set_display_name, on: [:create, :update]
  after_update_commit :send_welcome_email_if_approved

  private

  def set_defaults
    self.status ||= :pending
    self.rgpd_consent ||= false
    self.profile_image_attached ||= false
    self.picture_visible ||= false
    self.levels ||= []
    self.subjects_tags ||= []
    self.teaching_formats ||= []
    self.exam_tags ||= []
    self.pedagogy_tags ||= []
  end

  def set_display_name
    if first_name.present? && last_name.present?
      self.display_name = "#{first_name} #{last_name[0].upcase}"
    elsif first_name.present?
      self.display_name = first_name
    end
  end

  def send_welcome_email_if_approved
    return unless saved_change_to_status?
    return unless status == "approved"

    # Envoyer l'email de bienvenue seulement si on passe à approved
    previous_status = saved_change_to_status[0]
    if previous_status != "approved"
      Notifications::WelcomeNotifier.call(user)
    end
  end
end
