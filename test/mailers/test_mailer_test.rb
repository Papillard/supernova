require "test_helper"

class TestMailerTest < ActionMailer::TestCase
  test "ping" do
    mail = TestMailer.ping("to@example.org")
    assert_equal "ProfConnect SMTP OK", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_match "ping", mail.body.encoded
  end
end
