class CreateTeachers < ActiveRecord::Migration[8.0]
  def change
    create_table :teachers do |t|
      # Identité
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :display_name, null: false
      t.string :gender, null: false

      # Parcours / Établissement
      t.string :academy_name
      t.string :school_name
      t.string :career_status, null: false

      # Matières / Niveaux / Formats (arrays PostgreSQL)
      t.text :levels, array: true, default: []
      t.text :subjects_tags, array: true, default: []
      t.text :teaching_formats, array: true, default: []

      # Localisation
      t.string :base_city
      t.string :base_zip_code
      t.string :radius_text

      # Textes & Métiers
      t.text :support_text
      t.text :experience_text
      t.text :special_skills_text
      t.text :interest_text
      t.text :exams_raw_text

      # Tags
      t.text :exam_tags, array: true, default: []
      t.text :pedagogy_tags, array: true, default: []

      # Tarifs & Capacités
      t.text :pricing_text
      t.string :target_students_range

      # Données sensibles
      t.string :email_pro, null: false
      t.string :email_perso
      t.string :phone
      t.string :profile_image_url
      t.boolean :profile_image_attached, default: false, null: false

      # Statut & RGPD
      t.string :status, null: false, default: "pending"
      t.boolean :rgpd_consent, null: false, default: false

      t.timestamps
    end
  end
end
