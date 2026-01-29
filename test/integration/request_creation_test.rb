require "test_helper"

class RequestCreationIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent_user)
    @teacher = teachers(:approved_teacher)
    @student = students(:college_student)
    sign_in @parent
  end

  test "parent can create a request with existing student" do
    # Need a teacher with no existing active request from this parent
    teacher_user = User.create!(email: "fresh_teacher@example.com", password: "password123", role: "teacher")
    fresh_teacher = Teacher.create!(
      user: teacher_user, first_name: "Luc", last_name: "Blanc",
      display_name: "Luc B", status: "approved", rgpd_consent: true,
      profile_image_attached: false, levels: ["college"], subjects_tags: ["mathematiques"],
      teaching_formats: ["online"], city: "Paris"
    )

    assert_difference "Request.count", 1 do
      post requests_path, params: {
        teacher_id: fresh_teacher.id,
        request: {
          subject: "mathematiques",
          student_id: @student.id,
          notes: "Mon fils a besoin d'aide"
        }
      }
    end

    new_request = Request.last
    assert_equal "pending", new_request.status
    assert_equal @parent, new_request.parent
    assert_equal fresh_teacher, new_request.teacher
    assert_equal @student, new_request.student
    assert_redirected_to requests_path(id: new_request.id)
  end

  test "parent can create a request with new student" do
    teacher_user = User.create!(email: "fresh_teacher2@example.com", password: "password123", role: "teacher")
    fresh_teacher = Teacher.create!(
      user: teacher_user, first_name: "Claire", last_name: "Noir",
      display_name: "Claire N", status: "approved", rgpd_consent: true,
      profile_image_attached: false, levels: ["primaire"], subjects_tags: ["francais"],
      teaching_formats: ["online"], city: "Paris"
    )

    assert_difference ["Request.count", "Student.count"], 1 do
      post requests_path, params: {
        teacher_id: fresh_teacher.id,
        request: {
          subject: "francais",
          student_id: "new",
          student_attributes: { first_name: "Léa", birth_year: 2017 }
        }
      }
    end

    assert_redirected_to requests_path(id: Request.last.id)
  end

  test "parent cannot create duplicate active request with same teacher" do
    # pending_request fixture already exists for parent_user + approved_teacher
    assert_no_difference "Request.count" do
      post requests_path, params: {
        teacher_id: @teacher.id,
        request: {
          subject: "francais",
          student_id: @student.id,
          notes: "Duplicate"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "parent can view requests index" do
    get requests_path
    assert_response :success
  end

  test "parent can archive a request" do
    req = requests(:pending_request)
    patch archive_request_path(req)
    assert_redirected_to requests_path
    req.reload
    assert req.archived_by_parent
  end

  test "unauthenticated user cannot create request" do
    sign_out @parent
    post requests_path, params: {
      teacher_id: @teacher.id,
      request: { subject: "mathematiques", student_id: @student.id }
    }
    assert_redirected_to new_user_session_path
  end
end
