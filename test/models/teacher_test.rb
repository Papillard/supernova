require "test_helper"

class TeacherTest < ActiveSupport::TestCase
  test "valid teacher can be saved" do
    user = User.create!(email: "newteacher@example.com", password: "password123", role: "teacher")
    teacher = Teacher.new(user: user, first_name: "Paul", last_name: "Durand")
    assert teacher.valid?, teacher.errors.full_messages.join(", ")
  end

  test "first_name is required" do
    teacher = Teacher.new(first_name: nil, last_name: "Durand")
    assert_not teacher.valid?
    assert teacher.errors[:first_name].any?
  end

  test "last_name is required" do
    teacher = Teacher.new(first_name: "Paul", last_name: nil)
    assert_not teacher.valid?
    assert teacher.errors[:last_name].any?
  end

  test "status defaults to pending on create" do
    user = User.create!(email: "default@example.com", password: "password123", role: "teacher")
    teacher = Teacher.create!(user: user, first_name: "Paul", last_name: "Durand")
    assert_equal "pending", teacher.status
  end

  test "display_name auto-generated as FirstName L on create" do
    user = User.create!(email: "display@example.com", password: "password123", role: "teacher")
    teacher = Teacher.create!(user: user, first_name: "Marie", last_name: "Dupont")
    assert_equal "Marie D", teacher.display_name
  end

  test "display_name updated on update" do
    teacher = teachers(:pending_teacher)
    teacher.update!(first_name: "Pierre", last_name: "Lefevre")
    assert_equal "Pierre L", teacher.display_name
  end

  test "headline max 120 chars" do
    teacher = teachers(:pending_teacher)
    teacher.headline = "a" * 121
    assert_not teacher.valid?
    assert teacher.errors[:headline].any?
  end

  test "headline within 120 chars is valid" do
    teacher = teachers(:pending_teacher)
    teacher.headline = "a" * 120
    assert teacher.valid?, teacher.errors.full_messages.join(", ")
  end

  test "target_audience_tags max 2 items" do
    teacher = teachers(:pending_teacher)
    teacher.target_audience_tags = %w[eleves_en_difficulte eleves_autonomes_bons_eleves eleves_visant_excellence]
    assert_not teacher.valid?
    assert teacher.errors[:target_audience_tags].any?
  end

  test "target_audience_tags with 2 items is valid" do
    teacher = teachers(:pending_teacher)
    teacher.target_audience_tags = %w[eleves_en_difficulte eleves_autonomes_bons_eleves]
    assert teacher.valid?, teacher.errors.full_messages.join(", ")
  end

  test "user_id must be unique" do
    existing = teachers(:pending_teacher)
    teacher = Teacher.new(user: existing.user, first_name: "Autre", last_name: "Prof")
    assert_not teacher.valid?
    assert teacher.errors[:user_id].any?
  end

  test "profile_completed? returns true when all required fields present" do
    teacher = teachers(:approved_teacher)
    assert teacher.profile_completed?
  end

  test "profile_completed? returns false when missing required fields" do
    teacher = teachers(:pending_teacher)
    teacher.city = nil
    teacher.zip_code = nil
    teacher.rgpd_consent = false
    assert_not teacher.profile_completed?
  end

  test "public_visible? requires approved and rgpd_consent" do
    assert teachers(:approved_teacher).public_visible?
    assert_not teachers(:pending_teacher).public_visible?
  end

  test "public_visible scope returns only approved teachers with RGPD consent" do
    visible = Teacher.public_visible
    assert_includes visible, teachers(:approved_teacher)
    assert_not_includes visible, teachers(:pending_teacher)
  end
end
