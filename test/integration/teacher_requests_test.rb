require "test_helper"

class TeacherRequestsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @teacher_user = users(:teacher_user)
    @teacher = teachers(:pending_teacher)
    sign_in @teacher_user
  end

  test "teacher can view requests index" do
    get teacher_requests_path
    assert_response :success
  end

  test "teacher can accept a pending request" do
    req = requests(:accepted_request)
    # Reset to pending for this test
    req.update_columns(status: "pending", responded_at: nil)

    patch accept_teacher_request_path(req)
    assert_redirected_to teacher_requests_path(id: req.id)

    req.reload
    assert_equal "accepted", req.status
    assert_not_nil req.responded_at
  end

  test "teacher can decline a pending request" do
    req = requests(:accepted_request)
    req.update_columns(status: "pending", responded_at: nil)

    patch decline_teacher_request_path(req)
    assert_redirected_to teacher_requests_path(id: req.id)

    req.reload
    assert_equal "declined", req.status
    assert_not_nil req.responded_at
  end

  test "teacher can archive a request" do
    req = requests(:accepted_request)
    patch archive_teacher_request_path(req)
    assert_redirected_to teacher_requests_path

    req.reload
    assert req.archived_by_teacher
  end

  test "non-teacher user is redirected" do
    sign_out @teacher_user
    sign_in users(:parent_user)
    get teacher_requests_path
    assert_redirected_to root_path
  end
end
