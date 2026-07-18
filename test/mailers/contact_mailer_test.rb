require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  def attrs
    {
      "name" => "Marie Dupont",
      "email" => "marie@example.com",
      "subject" => "Question sur mon compte",
      "message" => "Bonjour, j'ai une question."
    }
  end

  test "contact_email is sent to the contact address" do
    mail = ContactMailer.contact_email(attrs)
    expected = ENV.fetch("CONTACT_EMAIL", "contact@prof-connect.fr")
    assert_equal [ expected ], mail.to
  end

  test "contact_email sets reply_to to the sender email" do
    mail = ContactMailer.contact_email(attrs)
    assert_equal [ "marie@example.com" ], mail.reply_to
  end

  test "contact_email subject is prefixed with [Contact ProfConnect]" do
    mail = ContactMailer.contact_email(attrs)
    assert_equal "[Contact ProfConnect] Question sur mon compte", mail.subject
  end

  test "contact_email body includes the sender details" do
    mail = ContactMailer.contact_email(attrs)
    assert_match "Marie Dupont", mail.body.encoded
    assert_match "marie@example.com", mail.body.encoded
    assert_match "Bonjour, j'ai une question.", mail.body.encoded
  end
end
