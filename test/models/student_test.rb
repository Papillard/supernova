require "test_helper"

class StudentTest < ActiveSupport::TestCase
  test "first_name is required" do
    student = Student.new(parent_profile: parent_profiles(:completed_profile), birth_year: 2013)
    assert_not student.valid?
    assert student.errors[:first_name].any?
  end

  test "birth_year is required" do
    student = Student.new(parent_profile: parent_profiles(:completed_profile), first_name: "Emma")
    assert_not student.valid?
    assert student.errors[:birth_year].any?
  end

  test "birth_year must be integer" do
    student = Student.new(parent_profile: parent_profiles(:completed_profile), first_name: "Emma", birth_year: 2012.5)
    assert_not student.valid?
    assert student.errors[:birth_year].any?
  end

  test "birth_year must be greater than 1900" do
    student = Student.new(parent_profile: parent_profiles(:completed_profile), first_name: "Emma", birth_year: 1899)
    assert_not student.valid?
  end

  test "birth_year must be less than or equal to current year" do
    student = Student.new(parent_profile: parent_profiles(:completed_profile), first_name: "Emma", birth_year: Date.current.year + 1)
    assert_not student.valid?
  end

  test "age computed from birth_year" do
    student = students(:college_student)
    expected_age = Date.current.year - student.birth_year
    assert_equal expected_age, student.age
  end

  test "age returns nil when birth_year is nil" do
    student = Student.new
    assert_nil student.age
  end

  test "level inferred from age - primaire" do
    student = Student.new(birth_year: Date.current.year - 8)
    assert_equal "primaire", student.level
  end

  test "level inferred from age - college" do
    student = Student.new(birth_year: Date.current.year - 12)
    assert_equal "college", student.level
  end

  test "level inferred from age - lycee" do
    student = Student.new(birth_year: Date.current.year - 16)
    assert_equal "lycee", student.level
  end

  test "level inferred from age - prepa" do
    student = Student.new(birth_year: Date.current.year - 19)
    assert_equal "prepa", student.level
  end

  test "level inferred from age - sup" do
    student = Student.new(birth_year: Date.current.year - 25)
    assert_equal "sup", student.level
  end

  test "level returns nil when birth_year is nil" do
    student = Student.new
    assert_nil student.level
  end
end
