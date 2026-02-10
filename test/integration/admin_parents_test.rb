require "test_helper"

class AdminParentsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @parent_profile = parent_profiles(:completed_profile)
    sign_in @admin
  end

  test "admin can view parents list" do
    get admin_parents_path
    assert_response :success
  end

  test "admin can filter parents by complete profile" do
    get admin_parents_path(filter: "complete")
    assert_response :success
  end

  test "admin can filter parents by incomplete profile" do
    get admin_parents_path(filter: "incomplete")
    assert_response :success
  end

  test "admin can view parent details" do
    get admin_parent_path(@parent_profile)
    assert_response :success
  end

  test "parent details shows students count" do
    get admin_parent_path(@parent_profile)
    assert_response :success
    assert_select "td", text: @parent_profile.students.first.first_name
  end

  test "non-admin user is redirected" do
    sign_out @admin
    sign_in users(:parent_user)
    get admin_parents_path
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to login" do
    sign_out @admin
    get admin_parents_path
    assert_redirected_to new_user_session_path
  end

  test "non-admin cannot view parent details" do
    sign_out @admin
    sign_in users(:parent_user)
    get admin_parent_path(@parent_profile)
    assert_redirected_to root_path
  end
end
