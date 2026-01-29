require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "body is required" do
    message = Message.new(request: requests(:pending_request), user: users(:parent_user), body: "")
    assert_not message.valid?
    assert message.errors[:body].any?
  end

  test "creates with valid request and user" do
    message = Message.new(
      request: requests(:pending_request),
      user: users(:parent_user),
      body: "Un nouveau message"
    )
    assert message.valid?, message.errors.full_messages.join(", ")
  end

  test "updates request last_message_at after create" do
    req = requests(:pending_request)
    old_last_message_at = req.last_message_at

    # Use a system message to skip the mailer notification callback
    Message.create!(
      request: req,
      user: users(:parent_user),
      body: "Message système de test",
      system: true
    )

    req.reload
    assert req.last_message_at > old_last_message_at
  end
end
