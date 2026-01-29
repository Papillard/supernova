require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "parent can sign up and is redirected to teachers page" do
    visit new_parent_registration_path

    assert_selector "h1", text: "ProfConnect"
    assert_selector "h2", text: "Créer un compte parent"

    fill_in "Email", with: "parent@example.com"
    fill_in "Mot de passe", with: "password123"
    fill_in "Confirmer le mot de passe", with: "password123"

    click_button "Créer mon compte"

    assert_current_path teachers_path
    assert_text "Le listing des professeurs sera implémenté dans un prochain sprint"
  end

  test "parent is created with parent role" do
    visit new_parent_registration_path

    fill_in "Email", with: "parent@example.com"
    fill_in "Mot de passe", with: "password123"
    fill_in "Confirmer le mot de passe", with: "password123"

    click_button "Créer mon compte"

    user = User.find_by(email: "parent@example.com")
    assert_not_nil user
    assert_equal "parent", user.role
  end

  test "teacher can sign up and is redirected to profile" do
    visit new_teacher_registration_path

    assert_selector "h1", text: "ProfConnect"
    assert_selector "h2", text: "Créer un compte professeur"

    fill_in "Email professionnel", with: "teacher@example.com"
    fill_in "Mot de passe", with: "password123"
    fill_in "Confirmer le mot de passe", with: "password123"

    click_button "Créer mon compte professeur"

    assert_current_path teacher_profile_path
  end

  test "teacher is created with teacher role" do
    visit new_teacher_registration_path

    fill_in "Email professionnel", with: "teacher@example.com"
    fill_in "Mot de passe", with: "password123"
    fill_in "Confirmer le mot de passe", with: "password123"

    click_button "Créer mon compte professeur"

    user = User.find_by(email: "teacher@example.com")
    assert_not_nil user
    assert_equal "teacher", user.role
  end

  test "user can log in and is redirected according to role" do
    # Create a parent user
    parent = User.create!(
      email: "parent@example.com",
      password: "password123",
      role: "parent"
    )

    visit new_user_session_path

    fill_in "Email", with: "parent@example.com"
    fill_in "Mot de passe", with: "password123"

    click_button "Se connecter"

    assert_current_path teachers_path
  end

  test "teacher user is redirected to profile after login" do
    # Create a teacher user
    teacher = User.create!(
      email: "teacher@example.com",
      password: "password123",
      role: "teacher"
    )

    visit new_user_session_path

    fill_in "Email", with: "teacher@example.com"
    fill_in "Mot de passe", with: "password123"

    click_button "Se connecter"

    assert_current_path teacher_profile_path
  end

  test "user can log out" do
    # Create and sign in a user
    user = User.create!(
      email: "user@example.com",
      password: "password123",
      role: "parent"
    )

    visit new_user_session_path
    fill_in "Email", with: "user@example.com"
    fill_in "Mot de passe", with: "password123"
    click_button "Se connecter"

    # Find and click logout button in dropdown
    find("label[tabindex='0']").click
    click_on "Déconnexion"

    assert_current_path root_path
  end

  test "password reset flow sends email" do
    user = User.create!(
      email: "user@example.com",
      password: "password123",
      role: "parent"
    )

    visit new_user_password_path

    fill_in "Email", with: "user@example.com"
    click_button "Envoyer les instructions"

    # Check that the reset token was generated
    user.reload
    assert_not_nil user.reset_password_token
    assert_not_nil user.reset_password_sent_at
  end

  test "user can reset password with valid token" do
    user = User.create!(
      email: "user@example.com",
      password: "password123",
      role: "parent"
    )

    # Request password reset
    visit new_user_password_path
    fill_in "Email", with: "user@example.com"
    click_button "Envoyer les instructions"

    # Get the reset token from the user
    user.reload
    token = user.reset_password_token

    # Visit the reset password page with the token
    visit edit_user_password_path(reset_password_token: token)

    fill_in "Nouveau mot de passe", with: "newpassword123"
    fill_in "Confirmer le nouveau mot de passe", with: "newpassword123"
    click_button "Changer mon mot de passe"

    # Should be able to login with new password
    visit new_user_session_path
    fill_in "Email", with: "user@example.com"
    fill_in "Mot de passe", with: "newpassword123"
    click_button "Se connecter"

    assert_current_path teachers_path
  end
end
