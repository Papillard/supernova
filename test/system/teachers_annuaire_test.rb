require "application_system_test_case"

class TeachersAnnuaireTest < ApplicationSystemTestCase
  test "annuaire shows only approved teachers with rgpd consent" do
    # Create approved teacher with consent
    user1 = User.create!(email: "teacher1@example.com", password: "password123", role: "teacher")
    teacher1 = Teacher.create!(
      user: user1,
      first_name: "Marie",
      last_name: "Dupont",
      display_name: "Marie D.",
      gender: "female",
      career_status: "certifié",
      email_pro: "teacher1@example.com",
      status: "approved",
      rgpd_consent: true,
      subjects_tags: ["Mathématiques"],
      base_city: "Paris"
    )

    # Create pending teacher (should not appear)
    user2 = User.create!(email: "teacher2@example.com", password: "password123", role: "teacher")
    Teacher.create!(
      user: user2,
      first_name: "Jean",
      last_name: "Martin",
      display_name: "Jean M.",
      gender: "male",
      career_status: "agrégé",
      email_pro: "teacher2@example.com",
      status: "pending",
      rgpd_consent: true
    )

    # Create approved teacher without consent (should not appear)
    user3 = User.create!(email: "teacher3@example.com", password: "password123", role: "teacher")
    Teacher.create!(
      user: user3,
      first_name: "Sophie",
      last_name: "Bernard",
      display_name: "Sophie B.",
      gender: "female",
      career_status: "certifié",
      email_pro: "teacher3@example.com",
      status: "approved",
      rgpd_consent: false
    )

    visit teachers_path

    # Should only see teacher1
    assert_text "Marie D."
    assert_no_text "Jean M."
    assert_no_text "Sophie B."
  end

  test "annuaire filters work" do
    user = User.create!(email: "teacher@example.com", password: "password123", role: "teacher")
    Teacher.create!(
      user: user,
      first_name: "Marie",
      last_name: "Dupont",
      display_name: "Marie D.",
      gender: "female",
      career_status: "certifié",
      email_pro: "teacher@example.com",
      status: "approved",
      rgpd_consent: true,
      subjects_tags: ["Mathématiques"],
      levels: ["6ème", "5ème"],
      base_city: "Paris"
    )

    visit teachers_path

    fill_in "Ville", with: "Paris"
    click_button "Filtrer"

    assert_text "Marie D."

    fill_in "Ville", with: "Lyon"
    click_button "Filtrer"

    assert_no_text "Marie D."
  end

  test "teacher show page does not expose sensitive data" do
    user = User.create!(email: "teacher@example.com", password: "password123", role: "teacher")
    teacher = Teacher.create!(
      user: user,
      first_name: "Marie",
      last_name: "Dupont",
      display_name: "Marie D.",
      gender: "female",
      career_status: "certifié",
      email_pro: "teacher@example.com",
      email_perso: "private@example.com",
      phone: "0612345678",
      status: "approved",
      rgpd_consent: true,
      subjects_tags: ["Mathématiques"]
    )

    visit teacher_path(teacher)

    # Should see public info
    assert_text "Marie D."
    assert_text "Mathématiques"

    # Should NOT see sensitive data
    assert_no_text "teacher@example.com"
    assert_no_text "private@example.com"
    assert_no_text "0612345678"
  end
end




