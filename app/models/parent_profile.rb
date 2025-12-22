class ParentProfile < ApplicationRecord
  belongs_to :user
  has_many :students, dependent: :destroy

  # Validations
  validates :user_id, uniqueness: true

  # Callbacks
  before_save :check_profile_completion

  # Scopes
  scope :completed, -> { where(profile_completed: true) }
  scope :incomplete, -> { where(profile_completed: false) }

  private

  def check_profile_completion
    self.profile_completed = first_name.present? &&
                             last_name.present? &&
                             students.exists?
  end
end

