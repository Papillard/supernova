require "test_helper"

class SubjectTest < ActiveSupport::TestCase
  test "valid subject" do
    subject = Subject.new(name: "Maths", slug: "maths-test", tag_code: "maths_test", display_name: "Maths")
    assert subject.valid?
  end

  test "slug must be unique" do
    subject = Subject.new(name: "Test", slug: subjects(:maths).slug, tag_code: "unique_code", display_name: "Test")
    assert_not subject.valid?
    assert subject.errors[:slug].any?
  end

  test "tag_code must be unique" do
    subject = Subject.new(name: "Test", slug: "unique-slug", tag_code: subjects(:maths).tag_code, display_name: "Test")
    assert_not subject.valid?
    assert subject.errors[:tag_code].any?
  end

  test "slug format validation" do
    subject = Subject.new(name: "Test", slug: "INVALID SLUG!", tag_code: "test", display_name: "Test")
    assert_not subject.valid?
    assert subject.errors[:slug].any?
  end

  test "requires name, slug, tag_code, display_name" do
    subject = Subject.new
    assert_not subject.valid?
    assert subject.errors[:name].any?
    assert subject.errors[:slug].any?
    assert subject.errors[:tag_code].any?
    assert subject.errors[:display_name].any?
  end
end
