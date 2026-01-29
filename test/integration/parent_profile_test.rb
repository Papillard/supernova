require "test_helper"

class ParentProfileIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent_user)
    sign_in @parent
  end

  # --- Profile ---

  test "parent can view profile page" do
    get parent_profile_path
    assert_response :success
  end

  test "parent can update profile" do
    patch parent_profile_path, params: {
      parent_profile: { first_name: "Nathalie", last_name: "Moreau", city: "Lyon", zip_code: "69001" }
    }
    assert_redirected_to parent_profile_path
    @parent.parent_profile.reload
    assert_equal "Nathalie", @parent.parent_profile.first_name
    assert_equal "Lyon", @parent.parent_profile.city
  end

  test "parent profile completion page works" do
    get parent_profile_complete_path
    assert_response :success
  end

  test "unauthenticated user is redirected from profile" do
    sign_out @parent
    get parent_profile_path
    assert_redirected_to new_user_session_path
  end

  # --- Students ---

  test "parent can add a student" do
    assert_difference "Student.count", 1 do
      post students_path, params: {
        student: { first_name: "Emma", birth_year: 2015 }
      }
    end
    assert_redirected_to parent_profile_path
  end

  test "parent cannot add student with invalid data" do
    assert_no_difference "Student.count" do
      post students_path, params: {
        student: { first_name: "", birth_year: nil }
      }
    end
  end

  test "parent can delete a student" do
    # Create a standalone student not referenced by any request
    student = @parent.parent_profile.students.create!(first_name: "Temp", birth_year: 2016)
    assert_difference "Student.count", -1 do
      delete student_path(student)
    end
    assert_redirected_to parent_profile_path
  end
end
