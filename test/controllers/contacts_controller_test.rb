require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  def valid_params
    {
      contact_message: {
        name: "Marie Dupont",
        email: "marie@example.com",
        subject: "Question sur mon compte",
        message: "Bonjour, j'ai une question au sujet de mon inscription."
      }
    }
  end

  test "GET /nous-contacter renders the form" do
    get contact_path
    assert_response :success
    assert_select "form[action=?]", contact_path
    assert_select "input[name=?]", "contact_message[name]"
    assert_select "textarea[name=?]", "contact_message[message]"
  end

  test "valid submission enqueues the contact email and redirects with a success flash" do
    assert_enqueued_emails 1 do
      post contact_path, params: valid_params
    end

    assert_redirected_to contact_path
    follow_redirect!
    assert_match "votre message a bien été envoyé", response.body
  end

  test "invalid submission re-renders the form with 422 and shows errors" do
    assert_no_enqueued_emails do
      post contact_path, params: valid_params.deep_merge(contact_message: { message: "" })
    end

    assert_response :unprocessable_entity
    assert_select "form[action=?]", contact_path
  end

  test "honeypot submission does not send an email but shows success" do
    assert_no_enqueued_emails do
      post contact_path, params: valid_params.deep_merge(contact_message: { company: "Spam Bot Inc" })
    end

    assert_redirected_to contact_path
  end

  test "signed-in user gets name and email prefilled" do
    user = users(:parent_user)
    sign_in user

    get contact_path
    assert_response :success
    assert_select "input[name=?][value=?]", "contact_message[name]", user.first_name
    assert_select "input[name=?][value=?]", "contact_message[email]", user.email
  end
end
