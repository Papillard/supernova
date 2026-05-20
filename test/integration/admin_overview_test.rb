require "test_helper"

class AdminOverviewIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "admin can view overview dashboard" do
    get admin_overview_path
    assert_response :success
  end

  test "overview shows summary cards" do
    get admin_overview_path
    assert_response :success
    assert_select ".card-title", text: "Total Professeurs"
    assert_select ".card-title", text: "Total Parents"
    assert_select ".card-title", text: /Total Requetes/
    assert_select ".card-title", text: "% Profs avec requetes"
  end

  test "overview shows monthly tables" do
    get admin_overview_path
    assert_response :success
    assert_select "h2", text: "Professeurs inscrits (cumule)"
    assert_select "h2", text: "Parents inscrits (cumule)"
    assert_select "h2", text: "Requetes par mois"
  end

  test "non-admin user is redirected" do
    sign_out @admin
    sign_in users(:parent_user)
    get admin_overview_path
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to login" do
    sign_out @admin
    get admin_overview_path
    assert_redirected_to new_user_session_path
  end
end
