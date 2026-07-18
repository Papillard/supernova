require "test_helper"

class ContactMessageTest < ActiveSupport::TestCase
  def valid_attributes
    {
      name: "Marie Dupont",
      email: "marie@example.com",
      subject: "Question sur mon compte",
      message: "Bonjour, j'ai une question au sujet de mon inscription."
    }
  end

  test "valid with correct attributes" do
    assert ContactMessage.new(valid_attributes).valid?
  end

  test "name is required" do
    message = ContactMessage.new(valid_attributes.merge(name: ""))
    assert_not message.valid?
    assert message.errors[:name].any?
  end

  test "email must have a valid format" do
    message = ContactMessage.new(valid_attributes.merge(email: "pas-un-email"))
    assert_not message.valid?
    assert message.errors[:email].any?
  end

  test "email is required" do
    message = ContactMessage.new(valid_attributes.merge(email: ""))
    assert_not message.valid?
    assert message.errors[:email].any?
  end

  test "subject is required" do
    message = ContactMessage.new(valid_attributes.merge(subject: ""))
    assert_not message.valid?
    assert message.errors[:subject].any?
  end

  test "message must be at least 10 characters" do
    message = ContactMessage.new(valid_attributes.merge(message: "trop"))
    assert_not message.valid?
    assert message.errors[:message].any?
  end

  test "message must not exceed 5000 characters" do
    message = ContactMessage.new(valid_attributes.merge(message: "a" * 5001))
    assert_not message.valid?
    assert message.errors[:message].any?
  end

  test "spam? is true when honeypot company is filled" do
    assert ContactMessage.new(valid_attributes.merge(company: "Acme Corp")).spam?
  end

  test "spam? is false when honeypot company is blank" do
    assert_not ContactMessage.new(valid_attributes).spam?
  end
end
