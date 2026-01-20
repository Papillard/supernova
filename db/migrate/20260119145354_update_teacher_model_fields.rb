class UpdateTeacherModelFields < ActiveRecord::Migration[8.0]
  def up
    # Étape 1: Ajouter les nouveaux champs temporairement
    add_column :teachers, :about_me_new, :text
    add_column :teachers, :headline, :string
    add_column :teachers, :primary_subject, :string
    add_column :teachers, :target_audience_tags, :text, array: true, default: []
    add_column :teachers, :accepted_requests_count, :integer, default: 0, null: false
    add_column :teachers, :specific_support_new, :text, array: true, default: []
    
    # Étape 2: Migrer les données (via Ruby pour plus de flexibilité)
    Teacher.reset_column_information
    Teacher.find_each do |teacher|
      # Concaténer les textes dans about_me
      about_me_parts = []
      about_me_parts << teacher.read_attribute(:support_text) if teacher.read_attribute(:support_text).present?
      about_me_parts << teacher.read_attribute(:special_skills_text) if teacher.read_attribute(:special_skills_text).present?
      about_me_parts << teacher.read_attribute(:experience_text) if teacher.read_attribute(:experience_text).present?
      about_me = about_me_parts.join("\n\n").strip
      
      # Générer headline
      headline = if teacher.read_attribute(:support_text).present?
        first_sentence = teacher.read_attribute(:support_text).split(/[.!?]/).first&.strip
        if first_sentence.present? && first_sentence.length <= 120
          first_sentence
        else
          teacher.read_attribute(:support_text)[0..117] + "..."
        end
      else
        "Professeur expérimenté"
      end
      
      # Primary subject
      primary_subject = teacher.subjects_tags.present? ? teacher.subjects_tags.first : "mathematiques"
      
      # Mettre à jour sans validation
      teacher.update_columns(
        about_me_new: about_me.presence,
        specific_support_new: teacher.read_attribute(:pedagogy_tags) || [],
        headline: headline,
        primary_subject: primary_subject,
        accepted_requests_count: 0
      )
    end
    
    # Étape 3: Renommer les colonnes
    rename_column :teachers, :support_text, :support_text_old
    rename_column :teachers, :about_me_new, :about_me
    rename_column :teachers, :pedagogy_tags, :pedagogy_tags_old
    rename_column :teachers, :specific_support_new, :specific_support
    
    # Étape 4: Supprimer les anciennes colonnes
    remove_column :teachers, :support_text_old, :text
    remove_column :teachers, :pedagogy_tags_old, :text
    remove_column :teachers, :experience_text, :text
    remove_column :teachers, :special_skills_text, :text
    remove_column :teachers, :interest_text, :text
  end

  def down
    # Restaurer les champs supprimés
    add_column :teachers, :experience_text, :text
    add_column :teachers, :special_skills_text, :text
    add_column :teachers, :interest_text, :text
    
    # Supprimer les nouveaux champs
    remove_column :teachers, :headline, :string
    remove_column :teachers, :primary_subject, :string
    remove_column :teachers, :target_audience_tags, :text
    remove_column :teachers, :accepted_requests_count, :integer
    
    # Renommer back
    rename_column :teachers, :about_me, :support_text
    rename_column :teachers, :specific_support, :pedagogy_tags
  end
end
