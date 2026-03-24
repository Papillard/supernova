require "test_helper"

class SeoPagesControllerTest < ActionDispatch::IntegrationTest
  test "subject_city returns 200 for published page" do
    get seo_subject_city_url(subject_slug: "maths", city_slug: "paris-15e")
    assert_response :success
  end

  test "subject_city includes H1" do
    get seo_subject_city_url(subject_slug: "maths", city_slug: "paris-15e")
    assert_match "Cours particuliers de Mathematiques a Paris 15e", response.body
  end

  test "subject_city includes meta tags" do
    get seo_subject_city_url(subject_slug: "maths", city_slug: "paris-15e")
    assert_match "Cours de Maths a Paris 15e | ProfConnect", response.body
  end

  test "subject_city includes FAQ schema markup" do
    get seo_subject_city_url(subject_slug: "maths", city_slug: "paris-15e")
    assert_match "FAQPage", response.body
    assert_match "application/ld+json", response.body
  end

  test "subject_city includes canonical link" do
    get seo_subject_city_url(subject_slug: "maths", city_slug: "paris-15e")
    assert_match 'rel="canonical"', response.body
  end

  test "subject_city returns 404 for invalid subject slug" do
    get seo_subject_city_url(subject_slug: "nonexistent", city_slug: "paris-15e")
    assert_response :not_found
  end

  test "subject_city returns 404 for invalid city slug" do
    get seo_subject_city_url(subject_slug: "maths", city_slug: "nonexistent")
    assert_response :not_found
  end

  test "subject_city returns 404 for unpublished page" do
    get seo_subject_city_url(subject_slug: "maths", city_slug: "paris-16e")
    assert_response :not_found
  end

  test "city_hub returns 200" do
    get seo_city_hub_url(city_slug: "paris-15e")
    assert_response :success
  end

  test "city_hub returns 404 for invalid city" do
    get seo_city_hub_url(city_slug: "nonexistent")
    assert_response :not_found
  end
end
