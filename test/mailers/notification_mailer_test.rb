require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "new_message_to_other_party works when parent sends message" do
    message = messages(:user_message)
    mail = NotificationMailer.new_message_to_other_party(message.id)

    assert_equal "Nouveau message de Marie sur ProfConnect", mail.subject
    # Recipient is the teacher's user (the other party)
    assert_equal [message.request.teacher.user.email], mail.to
  end

  test "new_message_to_other_party skips system messages" do
    message = messages(:system_message)
    mail = NotificationMailer.new_message_to_other_party(message.id)

    # System messages return early — no recipient, no subject
    assert_nil mail.perform_deliveries
  end

  test "new_request_to_teacher sends email to teacher" do
    req = requests(:pending_request)
    mail = NotificationMailer.new_request_to_teacher(req.id)

    assert_includes mail.subject, "Nouvelle demande"
    assert_equal [req.teacher.user.email], mail.to
  end

  test "request_accepted_to_parent sends email to parent" do
    req = requests(:accepted_request)
    mail = NotificationMailer.request_accepted_to_parent(req.id)

    assert_includes mail.subject, "accepté"
    assert_equal [req.parent.email], mail.to
  end

  test "request_declined_to_parent sends email to parent" do
    req = requests(:declined_request)
    mail = NotificationMailer.request_declined_to_parent(req.id)

    assert_includes mail.subject, "Réponse"
    assert_equal [req.parent.email], mail.to
  end
end
