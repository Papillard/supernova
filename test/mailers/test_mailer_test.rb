require "test_helper"

class TestMailerTest < ActionMailer::TestCase
  test "ping" do
    mail = TestMailer.ping
    assert_equal "Ping", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
