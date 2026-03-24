class City < ApplicationRecord
  has_many :seo_pages, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :department_code, presence: true

  scope :by_department, ->(code) { where(department_code: code) }
end
