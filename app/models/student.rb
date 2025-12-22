class Student < ApplicationRecord
  belongs_to :parent_profile

  # Validations
  validates :first_name, presence: true
  validates :birth_year, presence: true,
            numericality: {
              only_integer: true,
              greater_than: 1900,
              less_than_or_equal_to: -> { Date.current.year }
            }

  # Callbacks
  after_save :update_parent_profile_completion
  after_destroy :update_parent_profile_completion

  # Computed attributes
  def age
    return nil unless birth_year
    Date.current.year - birth_year
  end

  def level
    return nil unless birth_year
    age = self.age
    case age
    when 0..10
      "primaire"
    when 11..14
      "college"
    when 15..17
      "lycee"
    when 18..20
      "prepa"
    else
      "sup"
    end
  end

  private

  def update_parent_profile_completion
    parent_profile.save if parent_profile.persisted?
  end
end

