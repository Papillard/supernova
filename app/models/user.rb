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

  # Associations
  has_one :teacher, dependent: :destroy
  has_many :requests_as_parent, class_name: "Request", foreign_key: "parent_id", dependent: :destroy
  has_many :messages, dependent: :destroy
end
