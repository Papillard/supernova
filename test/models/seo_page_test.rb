require "test_helper"

class SeoPageTest < ActiveSupport::TestCase
  test "valid seo_page" do
    page = SeoPage.new(
      subject: subjects(:maths),
      city: cities(:boulogne),
      slug: "maths/boulogne",
      page_type: "subject_city",
      h1: "Cours de Maths a Boulogne"
    )
    assert page.valid?
  end

  test "published scope" do
    published = SeoPage.published
    assert published.include?(seo_pages(:maths_paris_15e))
    assert_not published.include?(seo_pages(:maths_paris_15e_unpublished))
  end

  test "content_block returns content" do
    page = seo_pages(:maths_paris_15e)
    assert_equal "Vous recherchez un professeur de mathematiques a Paris 15e ?", page.content_block("intro")
  end

  test "content_block returns nil for missing type" do
    page = seo_pages(:maths_paris_15e)
    assert_nil page.content_block("nonexistent")
  end

  test "faq_items returns structured array" do
    page = seo_pages(:maths_paris_15e)
    items = page.faq_items
    assert_equal 2, items.length
    assert_equal "Combien coute un cours ?", items[0][:question]
    assert_equal "Les tarifs varient selon le professeur.", items[0][:answer]
  end

  test "page_type must be valid" do
    page = SeoPage.new(city: cities(:paris_15e), slug: "test", page_type: "invalid", h1: "Test")
    assert_not page.valid?
    assert page.errors[:page_type].any?
  end

  test "subject is optional" do
    page = SeoPage.new(city: cities(:paris_15e), slug: "city-hub-test", page_type: "city_hub", h1: "Test")
    assert page.valid?
  end
end
