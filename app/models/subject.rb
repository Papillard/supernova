class Subject < ApplicationRecord
  has_many :seo_pages, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :tag_code, presence: true, uniqueness: true
  validates :display_name, presence: true
end
