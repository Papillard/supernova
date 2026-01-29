require "test_helper"

class ParentProfileTest < ActiveSupport::TestCase
  test "user_id must be unique" do
    existing = parent_profiles(:completed_profile)
    profile = ParentProfile.new(user: existing.user)
    assert_not profile.valid?
    assert profile.errors[:user_id].any?
  end

  test "profile_completed set to true when first_name, last_name, and student exist" do
    profile = parent_profiles(:completed_profile)
    assert profile.students.exists?
    profile.save!
    assert profile.profile_completed
  end

  test "profile_completed stays false when missing first_name" do
    profile = parent_profiles(:incomplete_profile)
    profile.first_name = ""
    profile.last_name = "Test"
    profile.save!
    assert_not profile.profile_completed
  end

  test "profile_completed stays false when no students" do
    user = User.create!(email: "noprofile@example.com", password: "password123", role: "parent")
    profile = ParentProfile.create!(user: user, first_name: "Test", last_name: "User")
    assert_not profile.profile_completed
  end

  test "completed scope returns completed profiles" do
    assert_includes ParentProfile.completed, parent_profiles(:completed_profile)
    assert_not_includes ParentProfile.completed, parent_profiles(:incomplete_profile)
  end

  test "incomplete scope returns incomplete profiles" do
    assert_includes ParentProfile.incomplete, parent_profiles(:incomplete_profile)
    assert_not_includes ParentProfile.incomplete, parent_profiles(:completed_profile)
  end
end
