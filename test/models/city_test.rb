require "test_helper"

class CityTest < ActiveSupport::TestCase
  test "valid city" do
    city = City.new(name: "Test City", slug: "test-city", department_code: "75")
    assert city.valid?
  end

  test "slug must be unique" do
    city = City.new(name: "Test", slug: cities(:paris_15e).slug, department_code: "75")
    assert_not city.valid?
    assert city.errors[:slug].any?
  end

  test "by_department scope" do
    paris_cities = City.by_department("75")
    assert paris_cities.include?(cities(:paris_15e))
    assert_not paris_cities.include?(cities(:boulogne))
  end

  test "requires name, slug, department_code" do
    city = City.new
    assert_not city.valid?
    assert city.errors[:name].any?
    assert city.errors[:slug].any?
    assert city.errors[:department_code].any?
  end
end
