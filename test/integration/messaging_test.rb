require "test_helper"

class MessagingIntegrationTest < ActionDispatch::IntegrationTest
  test "parent can send a message on their request" do
    sign_in users(:parent_user)
    req = requests(:pending_request)

    assert_difference "Message.count", 1 do
      post request_messages_path(req), params: {
        message: { body: "Merci pour votre réponse !" }
      }
    end
    assert_redirected_to requests_path(id: req.id)
  end

  test "teacher can send a message on their request" do
    sign_in users(:teacher_user)
    req = requests(:accepted_request)

    assert_difference "Message.count", 1 do
      post request_messages_path(req), params: {
        message: { body: "Bien sûr, je suis disponible." }
      }
    end
    assert_redirected_to teacher_requests_path(id: req.id)
  end

  test "cannot send empty message" do
    sign_in users(:parent_user)
    req = requests(:pending_request)

    assert_no_difference "Message.count" do
      post request_messages_path(req), params: {
        message: { body: "" }
      }
    end
  end

  test "unauthenticated user cannot send message" do
    req = requests(:pending_request)
    post request_messages_path(req), params: {
      message: { body: "Test" }
    }
    assert_redirected_to new_user_session_path
  end
end
