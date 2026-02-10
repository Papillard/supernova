class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enum for role
  enum :role, { parent: "parent", teacher: "teacher" }

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: %w[parent teacher] }

  # Associations (order matters: requests must be destroyed before parent_profile/students)
  has_one :teacher, dependent: :destroy
  has_many :requests_as_parent, class_name: "Request", foreign_key: "parent_id", dependent: :destroy
  has_many :messages, dependent: :destroy
  has_one :parent_profile, dependent: :destroy

  # Callbacks
  after_create_commit :send_welcome_email

  def admin?
    admin
  end

  # Compteur de requests non lues pour la pastille navbar
  def unread_requests_count
    if parent?
      requests_as_parent.unread_for_parent.count
    elsif teacher?
      teacher&.requests&.unread_for_teacher&.count || 0
    else
      0
    end
  end

  def has_unread_requests?
    unread_requests_count > 0
  end

  private

  def send_welcome_email
    Notifications::WelcomeNotifier.call(self)
  end
end
