require "test_helper"

class RequestTest < ActiveSupport::TestCase
  test "subject is required" do
    req = Request.new(
      parent: users(:parent_user),
      teacher: teachers(:approved_teacher),
      student: students(:college_student),
      level: "college",
      request_text: "test"
    )
    assert_not req.valid?
    assert req.errors[:subject].any?
  end

  test "level is required" do
    req = Request.new(
      parent: users(:parent_user),
      teacher: teachers(:approved_teacher),
      student: students(:college_student),
      subject: "mathematiques",
      request_text: "test"
    )
    assert_not req.valid?
    assert req.errors[:level].any?
  end

  test "student is required" do
    req = Request.new(
      parent: users(:parent_user),
      teacher: teachers(:approved_teacher),
      subject: "mathematiques",
      level: "college",
      request_text: "test"
    )
    assert_not req.valid?
    assert req.errors[:student].any?
  end

  test "requested_at auto-set on create" do
    # Use a teacher that has no active request with this parent
    user = User.create!(email: "newparent2@example.com", password: "password123", role: "parent")
    req = Request.create!(
      parent: user,
      teacher: teachers(:approved_teacher),
      student: students(:college_student),
      subject: "mathematiques",
      level: "college",
      request_text: "Bonjour"
    )
    assert_not_nil req.requested_at
  end

  test "cannot create active request with same parent and teacher pair" do
    existing = requests(:pending_request)
    req = Request.new(
      parent: existing.parent,
      teacher: existing.teacher,
      student: students(:college_student),
      subject: "francais",
      level: "college",
      request_text: "Autre demande"
    )
    assert_not req.valid?
    assert req.errors[:base].any?
  end

  test "7-day cooldown after declined request with same teacher" do
    # Create a recently declined request
    user = User.create!(email: "cooldown@example.com", password: "password123", role: "parent")
    declined = Request.create!(
      parent: user,
      teacher: teachers(:approved_teacher),
      student: students(:college_student),
      subject: "mathematiques",
      level: "college",
      request_text: "Premier contact"
    )
    declined.update_columns(status: "declined", responded_at: 2.days.ago)

    req = Request.new(
      parent: user,
      teacher: teachers(:approved_teacher),
      student: students(:college_student),
      subject: "francais",
      level: "college",
      request_text: "Nouveau contact"
    )
    assert_not req.valid?
    assert req.errors[:base].any?
  end

  test "active scope returns pending and accepted requests" do
    active = Request.active
    assert_includes active, requests(:pending_request)
    assert_includes active, requests(:accepted_request)
    assert_not_includes active, requests(:declined_request)
  end

  test "visible_to_parent scope excludes archived by parent" do
    req = requests(:pending_request)
    req.update_column(:archived_by_parent, true)
    assert_not_includes Request.visible_to_parent, req
  end

  test "visible_to_teacher scope excludes archived by teacher" do
    req = requests(:pending_request)
    req.update_column(:archived_by_teacher, true)
    assert_not_includes Request.visible_to_teacher, req
  end

  test "mark_as_read_by_parent! updates parent_last_read_at" do
    req = requests(:pending_request)
    assert_nil req.parent_last_read_at
    req.mark_as_read_by_parent!
    req.reload
    assert_not_nil req.parent_last_read_at
  end

  test "mark_as_read_by_teacher! updates teacher_last_read_at" do
    req = requests(:pending_request)
    assert_nil req.teacher_last_read_at
    req.mark_as_read_by_teacher!
    req.reload
    assert_not_nil req.teacher_last_read_at
  end
end
