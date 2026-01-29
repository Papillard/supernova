require "test_helper"

class AccountIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:parent_user)
    sign_in @user
  end

  test "user can view account page" do
    get account_path
    assert_response :success
  end

  test "user can update email with correct password" do
    patch account_path, params: {
      update_type: "email",
      user: { email: "newemail@example.com", current_password: "password123" }
    }
    assert_redirected_to account_path

    @user.reload
    assert_equal "newemail@example.com", @user.email
  end

  test "user cannot update email without current password" do
    patch account_path, params: {
      update_type: "email",
      user: { email: "newemail@example.com", current_password: "" }
    }
    assert_response :unprocessable_entity

    @user.reload
    assert_equal "parent@example.com", @user.email
  end

  test "user can update password with correct current password" do
    patch account_path, params: {
      update_type: "password",
      user: { password: "newpassword123", password_confirmation: "newpassword123", current_password: "password123" }
    }
    assert_redirected_to account_path
  end

  test "user cannot update password without current password" do
    patch account_path, params: {
      update_type: "password",
      user: { password: "newpassword123", password_confirmation: "newpassword123", current_password: "" }
    }
    assert_response :unprocessable_entity
  end

  test "user cannot update password with wrong current password" do
    patch account_path, params: {
      update_type: "password",
      user: { password: "newpassword123", password_confirmation: "newpassword123", current_password: "wrongpassword" }
    }
    assert_response :unprocessable_entity
  end

  test "unauthenticated user is redirected" do
    sign_out @user
    get account_path
    assert_redirected_to new_user_session_path
  end
end
