require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user can be saved" do
    user = User.new(
      email: "new@example.com",
      password: "password123",
      role: "parent"
    )
    assert user.valid?
  end

  test "email must be present" do
    user = User.new(email: "", password: "password123", role: "parent")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "email must be unique" do
    existing = users(:parent_user)
    user = User.new(email: existing.email, password: "password123", role: "parent")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "role must be present" do
    user = User.new(email: "test@example.com", password: "password123", role: nil)
    assert_not user.valid?
  end

  test "role must be parent or teacher" do
    user = User.new(email: "test@example.com", password: "password123")
    assert_raises(ArgumentError) { user.role = "student" }
  end

  test "has_one teacher association" do
    teacher_user = users(:teacher_user)
    assert_respond_to teacher_user, :teacher
    assert_equal teachers(:pending_teacher), teacher_user.teacher
  end

  test "has_one parent_profile association" do
    parent_user = users(:parent_user)
    assert_respond_to parent_user, :parent_profile
    assert_equal parent_profiles(:completed_profile), parent_user.parent_profile
  end

  test "has_many requests_as_parent association" do
    parent_user = users(:parent_user)
    assert_respond_to parent_user, :requests_as_parent
    assert_includes parent_user.requests_as_parent, requests(:pending_request)
  end

  test "has_many messages association" do
    parent_user = users(:parent_user)
    assert_respond_to parent_user, :messages
    assert_includes parent_user.messages, messages(:user_message)
  end

  test "admin? returns true for admin users" do
    assert users(:admin_user).admin?
    assert_not users(:parent_user).admin?
  end
end
