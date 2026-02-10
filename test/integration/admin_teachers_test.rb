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

  test "admin can access edit page" do
    get edit_admin_teacher_path(teachers(:pending_teacher))
    assert_response :success
  end

  test "admin can update teacher fields" do
    teacher = teachers(:pending_teacher)
    patch admin_teacher_path(teacher), params: { teacher: {
      first_name: "Pierre",
      last_name: "Dupont",
      headline: "Maths expert",
      city: "Lyon",
      zip_code: "69001",
      subjects_tags: ["francais", "anglais"],
      levels: ["primaire"],
      teaching_formats: ["online", "at_student_home"],
      status: "approved"
    } }
    assert_redirected_to admin_teacher_path(teacher)

    teacher.reload
    assert_equal "Pierre", teacher.first_name
    assert_equal "Dupont", teacher.last_name
    assert_equal "Maths expert", teacher.headline
    assert_equal "Lyon", teacher.city
    assert_equal "69001", teacher.zip_code
    assert_includes teacher.subjects_tags, "francais"
    assert_includes teacher.levels, "primaire"
    assert_includes teacher.teaching_formats, "online"
    assert_equal "approved", teacher.status
  end

  test "admin update does not change excluded contact fields" do
    teacher = teachers(:pending_teacher)
    original_email_pro = teacher.email_pro
    original_email_perso = teacher.email_perso
    original_phone = teacher.phone

    patch admin_teacher_path(teacher), params: { teacher: {
      first_name: "Modifié",
      email_pro: "hacked@example.com",
      email_perso: "hacked2@example.com",
      phone: "0600000000"
    } }
    assert_redirected_to admin_teacher_path(teacher)

    teacher.reload
    assert_equal "Modifié", teacher.first_name
    assert_nil teacher.email_pro
    assert_nil teacher.email_perso
    assert_nil teacher.phone
  end

  test "non-admin user cannot access edit page" do
    sign_out @admin
    sign_in users(:parent_user)
    get edit_admin_teacher_path(teachers(:pending_teacher))
    assert_redirected_to root_path
  end

  test "non-admin user cannot update teacher" do
    sign_out @admin
    sign_in users(:parent_user)
    patch admin_teacher_path(teachers(:pending_teacher)), params: { teacher: { first_name: "Hacked" } }
    assert_redirected_to root_path

    teachers(:pending_teacher).reload
    assert_equal "Jean", teachers(:pending_teacher).first_name
  end

  test "admin can destroy a teacher and associated user" do
    teacher = teachers(:pending_teacher)
    user = teacher.user

    assert_difference "Teacher.count", -1 do
      assert_difference "User.count", -1 do
        delete admin_teacher_path(teacher)
      end
    end

    assert_redirected_to admin_teachers_path
    assert_not Teacher.exists?(teacher.id)
    assert_not User.exists?(user.id)
  end

  test "non-admin user cannot destroy a teacher" do
    sign_out @admin
    sign_in users(:parent_user)
    delete admin_teacher_path(teachers(:pending_teacher))
    assert_redirected_to root_path
    assert Teacher.exists?(teachers(:pending_teacher).id)
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
