class SeoContent < ApplicationRecord
  belongs_to :seo_page

  validates :block_type, presence: true, inclusion: { in: %w[intro why_us faq how_it_works] }
  validates :content, presence: true
end
