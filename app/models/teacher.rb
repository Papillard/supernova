class Teacher < ApplicationRecord
  belongs_to :user

  # Constantes pour career_status
  # On stocke les CLÉS en DB (certifie, agrege) pour éviter les problèmes d'accents
  # L'affichage avec accents est géré dans les helpers via CAREER_STATUS_DISPLAY
  CAREER_STATUS_VALUES = {
    certifie: "certifie",
    agrege: "agrege",
    prof_des_ecoles: "prof_des_ecoles",
    autre: "autre"
  }.freeze

  # Mapping pour l'affichage (clé -> valeur avec accent)
  CAREER_STATUS_DISPLAY = {
    certifie: "certifié",
    agrege: "agrégé",
    prof_des_ecoles: "prof des écoles",
    autre: "autre"
  }.freeze

  # Enums
  enum :gender, { female: "female", male: "male", other: "other" }
  enum :career_status, CAREER_STATUS_VALUES
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
  validates :email_pro, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :status, presence: true
  validates :user_id, uniqueness: true
  validates :headline, length: { maximum: 120 }, allow_blank: true
  # primary_subject est optionnel
  validate :target_audience_tags_max_two
  validate :validate_array_values
  validate :career_status_inclusion

  # Associations
  has_many :requests, dependent: :destroy
  has_many_attached :verification_documents

  # Scopes
  scope :approved, -> { where(status: :approved) }
  scope :with_rgpd_consent, -> { where(rgpd_consent: true) }
  scope :public_visible, -> { approved.with_rgpd_consent }

  # Vérifie si le profil est visible publiquement (validé et avec consentement RGPD)
  def public_visible?
    approved? && rgpd_consent?
  end

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
    self.levels ||= []
    self.subjects_tags ||= []
    self.teaching_formats ||= []
    self.exam_tags ||= []
    self.specific_support ||= []
    self.target_audience_tags ||= []
    self.accepted_requests_count ||= 0
  end

  def target_audience_tags_max_two
    return unless target_audience_tags.present?
    if target_audience_tags.length > 2
      errors.add(:target_audience_tags, "ne peut contenir que 2 éléments maximum")
    end
  end

  def career_status_inclusion
    return if career_status.blank? # career_status est optionnel
    
    valid_values = CAREER_STATUS_VALUES.values
    unless valid_values.include?(career_status.to_s)
      errors.add(:career_status, "doit être une des valeurs valides: #{valid_values.join(', ')}")
    end
  end

  def validate_array_values
    # Extraire les valeurs valides des constantes
    valid_exam_tags = TeachersHelper::EXAM_TAGS_OPTIONS.map { |_, value| value }
    valid_specific_support = TeachersHelper::SPECIFIC_SUPPORT_OPTIONS.map { |_, value| value }
    valid_target_audience_tags = TeachersHelper::TARGET_AUDIENCE_TAGS_OPTIONS.map { |_, value| value }
    valid_subjects = TeachersHelper::SUBJECTS_OPTIONS.map { |_, value| value }
    valid_levels = TeachersHelper::LEVELS_OPTIONS.map { |_, value| value }
    valid_teaching_formats = ["online", "at_student_home", "at_teacher_home"]

    # Valider exam_tags
    if exam_tags.present? && exam_tags.any?
      invalid_tags = exam_tags.reject { |tag| valid_exam_tags.include?(tag.to_s) }
      if invalid_tags.any?
        errors.add(:exam_tags, "contient des valeurs invalides: #{invalid_tags.join(', ')}")
      end
    end

    # Valider specific_support
    if specific_support.present? && specific_support.any?
      invalid_tags = specific_support.reject { |tag| valid_specific_support.include?(tag.to_s) }
      if invalid_tags.any?
        errors.add(:specific_support, "contient des valeurs invalides: #{invalid_tags.join(', ')}")
      end
    end

    # Valider target_audience_tags
    if target_audience_tags.present? && target_audience_tags.any?
      invalid_tags = target_audience_tags.reject { |tag| valid_target_audience_tags.include?(tag.to_s) }
      if invalid_tags.any?
        errors.add(:target_audience_tags, "contient des valeurs invalides: #{invalid_tags.join(', ')}")
      end
    end

    # Valider subjects_tags
    if subjects_tags.present? && subjects_tags.any?
      invalid_tags = subjects_tags.reject { |tag| valid_subjects.include?(tag.to_s) }
      if invalid_tags.any?
        errors.add(:subjects_tags, "contient des valeurs invalides: #{invalid_tags.join(', ')}")
      end
    end

    # Valider levels
    if levels.present? && levels.any?
      invalid_levels = levels.reject { |level| valid_levels.include?(level.to_s) }
      if invalid_levels.any?
        errors.add(:levels, "contient des valeurs invalides: #{invalid_levels.join(', ')}")
      end
    end

    # Valider teaching_formats
    if teaching_formats.present? && teaching_formats.any?
      invalid_formats = teaching_formats.reject { |format| valid_teaching_formats.include?(format.to_s) }
      if invalid_formats.any?
        errors.add(:teaching_formats, "contient des valeurs invalides: #{invalid_formats.join(', ')}")
      end
    end
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
