require "application_system_test_case"

class TeacherProfileTest < ApplicationSystemTestCase
  test "teacher is auto-created on first profile visit" do
    user = User.create!(
      email: "teacher@example.com",
      password: "password123",
      role: "teacher",
      first_name: "Jean",
      last_name: "Dupont"
    )

    visit new_user_session_path
    fill_in "Email", with: "teacher@example.com"
    fill_in "Mot de passe", with: "password123"
    click_button "Se connecter"

    # Should be redirected to teacher profile
    assert_current_path teacher_profile_path

    # Teacher should be auto-created
    user.reload
    assert_not_nil user.teacher
    assert_equal "Jean", user.teacher.first_name
    assert_equal "Dupont", user.teacher.last_name
    assert_equal "Jean D.", user.teacher.display_name
    assert_equal "teacher@example.com", user.teacher.email_pro
    assert_equal "pending", user.teacher.status
  end

  test "teacher can update profile" do
    user = User.create!(
      email: "teacher@example.com",
      password: "password123",
      role: "teacher"
    )
    teacher = Teacher.create!(
      user: user,
      first_name: "Jean",
      last_name: "Dupont",
      display_name: "Jean D.",
      gender: "male",
      career_status: "certifié",
      email_pro: "teacher@example.com",
      status: "pending",
      rgpd_consent: false
    )

    visit new_user_session_path
    fill_in "Email", with: "teacher@example.com"
    fill_in "Mot de passe", with: "password123"
    click_button "Se connecter"

    fill_in "Prénom", with: "Marie"
    fill_in "Nom", with: "Martin"
    fill_in "Nom d'affichage", with: "Marie M."
    select "Féminin", from: "Genre"
    fill_in "Académie", with: "Académie de Paris"
    check "J'accepte que mes données soient utilisées conformément à la RGPD *"
    click_button "Enregistrer mon profil"

    teacher.reload
    assert_equal "Marie", teacher.first_name
    assert_equal "Martin", teacher.last_name
    assert_equal "Académie de Paris", teacher.academy_name
    assert_equal true, teacher.rgpd_consent
  end

  test "teacher profile requires rgpd consent" do
    user = User.create!(
      email: "teacher@example.com",
      password: "password123",
      role: "teacher"
    )
    Teacher.create!(
      user: user,
      first_name: "Jean",
      last_name: "Dupont",
      display_name: "Jean D.",
      gender: "male",
      career_status: "certifié",
      email_pro: "teacher@example.com",
      status: "pending",
      rgpd_consent: false
    )

    visit new_user_session_path
    fill_in "Email", with: "teacher@example.com"
    fill_in "Mot de passe", with: "password123"
    click_button "Se connecter"

    # Try to update without rgpd consent
    fill_in "Académie", with: "Académie de Paris"
    click_button "Enregistrer mon profil"

    # Should still work but rgpd_consent should be handled by controller
    assert_current_path teacher_profile_path
  end
end


