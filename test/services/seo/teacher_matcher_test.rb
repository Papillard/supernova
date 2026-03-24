require "test_helper"

class Seo::TeacherMatcherTest < ActiveSupport::TestCase
  setup do
    @maths = subjects(:maths)
    @paris_15e = cities(:paris_15e)
    @boulogne = cities(:boulogne)

    # Create a teacher visible in Paris zone with maths
    @paris_maths_user = User.create!(
      email: "seo_paris_maths@example.com",
      password: "password123",
      role: "teacher",
      first_name: "Test",
      last_name: "ParisM"
    )
    @paris_maths_teacher = Teacher.create!(
      user: @paris_maths_user,
      first_name: "Test",
      last_name: "ParisM",
      status: "approved",
      rgpd_consent: true,
      primary_subject: "mathematiques",
      subjects_tags: ["mathematiques", "physique-chimie"],
      city: "Paris",
      zip_code: "75015",
      served_zones: ["ile_de_france:paris"],
      levels: ["college"],
      teaching_formats: ["online"]
    )

    # Create a teacher in Boulogne with francais
    @boulogne_fr_user = User.create!(
      email: "seo_boulogne_fr@example.com",
      password: "password123",
      role: "teacher",
      first_name: "Test",
      last_name: "BoulogneF"
    )
    @boulogne_fr_teacher = Teacher.create!(
      user: @boulogne_fr_user,
      first_name: "Test",
      last_name: "BoulogneF",
      status: "approved",
      rgpd_consent: true,
      primary_subject: "francais",
      subjects_tags: ["francais"],
      city: "Boulogne-Billancourt",
      zip_code: "92100",
      served_zones: ["ile_de_france:petite_couronne"],
      levels: ["lycee"],
      teaching_formats: ["at_student_home"]
    )
  end

  test "matches teacher by subject tag_code against primary_subject" do
    results = Seo::TeacherMatcher.new(subject: @maths, city: @paris_15e).call
    assert_includes results, @paris_maths_teacher
    assert_not_includes results, @boulogne_fr_teacher
  end

  test "matches teacher by served_zones overlap" do
    results = Seo::TeacherMatcher.new(subject: @maths, city: @paris_15e).call
    assert_includes results, @paris_maths_teacher
  end

  test "matches teacher by city name" do
    # Boulogne teacher matches by city name
    francais = subjects(:francais)
    results = Seo::TeacherMatcher.new(subject: francais, city: @boulogne).call
    assert_includes results, @boulogne_fr_teacher
  end

  test "matches teacher by zip_code department prefix" do
    results = Seo::TeacherMatcher.new(subject: @maths, city: @paris_15e).call
    # @paris_maths_teacher has zip 75015, paris_15e has dept 75
    assert_includes results, @paris_maths_teacher
  end

  test "matches Paris arrondissement via parent_city" do
    # paris_15e has parent_city "Paris", teacher has city "Paris"
    results = Seo::TeacherMatcher.new(subject: @maths, city: @paris_15e).call
    assert_includes results, @paris_maths_teacher
  end

  test "excludes non-approved teachers" do
    pending_teacher = teachers(:pending_teacher)
    pending_teacher.update_columns(
      subjects_tags: ["mathematiques"],
      primary_subject: "mathematiques",
      served_zones: ["ile_de_france:paris"],
      city: "Paris"
    )
    results = Seo::TeacherMatcher.new(subject: @maths, city: @paris_15e).call
    assert_not_includes results, pending_teacher
  end

  test "city-only matching without subject" do
    results = Seo::TeacherMatcher.new(city: @paris_15e).call
    assert_includes results, @paris_maths_teacher
  end
end
