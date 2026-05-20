require "test_helper"

class AdminRequestsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @request = requests(:pending_request)
    sign_in @admin
  end

  test "admin can view requests list" do
    get admin_requests_path
    assert_response :success
    assert_select "h1", text: "Administration - Demandes"
  end

  test "requests list shows the existing requests" do
    get admin_requests_path
    assert_response :success
    assert_select "table"
    # parent_user has first_name "Marie" and last_name "Dupont"
    assert_select "td", text: /Marie Dupont/
  end

  test "admin can view a request detail" do
    get admin_request_path(@request)
    assert_response :success
    assert_select "h1", text: /Mathématiques/
  end

  test "request detail shows parent and teacher cards" do
    get admin_request_path(@request)
    assert_response :success
    assert_select "h2.card-title", text: "Parent"
    assert_select "h2.card-title", text: "Professeur"
  end

  test "request detail shows the conversation" do
    get admin_request_path(@request)
    assert_response :success
    assert_select "h2.card-title", text: /Conversation/
    # Pending request has one parent message in fixtures
    assert_select "#admin-message-#{messages(:user_message).id}"
  end

  test "request detail shows accepted status badge" do
    accepted = requests(:accepted_request)
    get admin_request_path(accepted)
    assert_response :success
    assert_select ".badge", text: "Acceptée"
  end

  test "non-admin user is redirected on index" do
    sign_out @admin
    sign_in users(:parent_user)
    get admin_requests_path
    assert_redirected_to root_path
  end

  test "non-admin user is redirected on show" do
    sign_out @admin
    sign_in users(:parent_user)
    get admin_request_path(@request)
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to login on index" do
    sign_out @admin
    get admin_requests_path
    assert_redirected_to new_user_session_path
  end

  test "unauthenticated user is redirected to login on show" do
    sign_out @admin
    get admin_request_path(@request)
    assert_redirected_to new_user_session_path
  end

  test "overview links to requests page via total requests card" do
    get admin_overview_path
    assert_response :success
    assert_select "a[href=?]", admin_requests_path
  end
end
