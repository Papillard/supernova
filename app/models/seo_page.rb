class SeoPage < ApplicationRecord
  belongs_to :subject, optional: true
  belongs_to :city
  has_many :seo_contents, dependent: :destroy

  validates :slug, presence: true, uniqueness: true
  validates :page_type, presence: true, inclusion: { in: %w[subject_city city_hub] }
  validates :h1, presence: true

  scope :published, -> { where(published: true) }

  def content_block(type)
    seo_contents.find_by(block_type: type)&.content
  end

  def faq_items
    seo_contents.where(block_type: "faq").order(:position).map do |content|
      parts = content.content.split("\n", 2)
      { question: parts[0].to_s.strip, answer: parts[1].to_s.strip }
    end
  end
end
