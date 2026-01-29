require "test_helper"

class AdminTeachersIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "admin can view teachers list" do
    get admin_teachers_path
    assert_response :success
  end

  test "admin can filter teachers by status" do
    get admin_teachers_path(status: "pending")
    assert_response :success
  end

  test "admin can view teacher details" do
    get admin_teacher_path(teachers(:pending_teacher))
    assert_response :success
  end

  test "admin can approve a teacher" do
    teacher = teachers(:pending_teacher)
    patch approve_admin_teacher_path(teacher)
    assert_redirected_to admin_teacher_path(teacher)

    teacher.reload
    assert_equal "approved", teacher.status
  end

  test "admin can reject a teacher" do
    teacher = teachers(:pending_teacher)
    patch reject_admin_teacher_path(teacher)
    assert_redirected_to admin_teacher_path(teacher)

    teacher.reload
    assert_equal "rejected", teacher.status
  end

  test "non-admin user is redirected" do
    sign_out @admin
    sign_in users(:parent_user)
    get admin_teachers_path
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected" do
    sign_out @admin
    get admin_teachers_path
    assert_redirected_to new_user_session_path
  end
end
