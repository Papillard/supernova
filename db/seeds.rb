# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'yaml'

# Helper pour obtenir une URL de photo placeholder
def random_photo_url(gender, index)
  # Utiliser ui-avatars.com qui génère des avatars basés sur des noms
  # Plus performant et fiable que randomuser.me
  # On utilise l'index pour varier les photos
  seed = (index * 7) % 100  # Varier les seeds pour avoir différentes photos
  if gender == "female"
    "https://i.pravatar.cc/300?img=#{seed + 20}"
  else
    "https://i.pravatar.cc/300?img=#{seed + 60}"
  end
end

# Helper pour nettoyer les niveaux
def clean_levels(levels)
  return [] if levels.nil?
  valid_levels = ["primaire", "college", "lycee", "prepa", "autre"]
  levels.select { |l| valid_levels.include?(l) }
end

# Helper pour nettoyer les matières
def clean_subjects(subjects)
  return [] if subjects.nil?
  valid_subjects = TeachersHelper::SUBJECTS_OPTIONS.map { |_, v| v }
  # Mapping des valeurs du YAML vers les valeurs du helper
  # Note: certaines matières gardent les tirets, d'autres utilisent des underscores
  subject_mapping = {
    "histoire-geographie" => "histoire-geographie",
    "histoire-geo" => "histoire-geographie",
    "hggsp" => "hggsp",
    "emc" => "emc",
    "mathematiques" => "mathematiques",
    "maths" => "mathematiques",
    "francais" => "francais",
    "anglais" => "anglais",
    "espagnol" => "espagnol",
    "allemand" => "allemand",
    "italien" => "italien",
    "physique-chimie" => "physique-chimie",
    "svt" => "svt",
    "ses" => "ses",
    "technologie" => "technologie",
    "snt" => "snt",
    "nsi" => "nsi",
    "geopolitique" => "geopolitique",
    "sciences-politiques" => "sciences_politiques",
    "sciences_politiques" => "sciences_politiques",
    "litterature" => "litterature",
    "philosophie" => "philosophie",
    "portugais" => "portugais",
    "education-musicale" => "education-musicale",
    "toutes-matieres-primaire" => "toutes_matieres_primaire",
    "toutes_matieres_primaire" => "toutes_matieres_primaire"
  }
  cleaned = subjects.map do |s|
    # Essayer le mapping d'abord
    mapped = subject_mapping[s] || subject_mapping[s.gsub("_", "-")] || s
    # Si pas dans les valeurs valides, essayer de convertir
    if !valid_subjects.include?(mapped)
      # Essayer avec underscore si c'était un tiret
      mapped = mapped.gsub("-", "_") if mapped.include?("-")
    end
    mapped
  end.select { |s| valid_subjects.include?(s) }
  cleaned.uniq
end

# Helper pour nettoyer les exam_tags
def clean_exam_tags(tags)
  return [] if tags.nil?
  valid_tags = TeachersHelper::EXAM_TAGS_OPTIONS.map { |_, v| v }
  # Mapping des anciennes valeurs
  tag_mapping = {
    "bac_general" => "bac_general",
    "bac-general" => "bac_general",
    "grand_oral" => "grand_oral",
    "grand-oral" => "grand_oral",
    "brevet" => "brevet",
    "sciences_po" => "concours_ieP_sciences_po",
    "sciences-po" => "concours_ieP_sciences_po",
    "ecoles_de_commerce" => "concours_ecole_commerce",
    "ecoles-de-commerce" => "concours_ecole_commerce"
  }
  tags.map do |t|
    mapped = tag_mapping[t] || t.gsub("-", "_")
    mapped
  end.select { |t| valid_tags.include?(t) }
end

# Helper pour nettoyer les pedagogy_tags
def clean_pedagogy_tags(tags)
  return [] if tags.nil?
  valid_tags = TeachersHelper::PEDAGOGY_TAGS_OPTIONS.map { |_, v| v }
  # Mapping des anciennes valeurs
  tag_mapping = {
    "methodologie" => "methodologie_travail",
    "methodologie_travail" => "methodologie_travail",
    "eleves_en_difficulte" => "eleves_en_difficulte",
    "eleves-en-difficulte" => "eleves_en_difficulte",
    "orientation" => "orientation",
    "parcoursup" => "parcoursup"
  }
  tags.map do |t|
    mapped = tag_mapping[t] || t.gsub("-", "_")
    mapped
  end.select { |t| valid_tags.include?(t) }
end

# Helper pour nettoyer les teaching_formats
def clean_teaching_formats(formats)
  return [] if formats.nil?
  valid_formats = ["online", "at_student_home", "at_teacher_home"]
  formats.select { |f| valid_formats.include?(f) }
end

# Nettoyer les données existantes
# Ordre important : supprimer d'abord les dépendances, puis les tables principales
puts "Nettoyage des données existantes..."

# 1. Supprimer les email_events (dépend de requests et users)
EmailEvent.destroy_all if defined?(EmailEvent)

# 2. Supprimer les messages (dépend de requests et users)
Message.destroy_all

# 3. Supprimer les requests (dépend de teachers, students, et users)
Request.destroy_all

# 4. Supprimer les teacher_documents (dépend de teachers)
# Pas de modèle, on supprime directement depuis la table si elle existe
if ActiveRecord::Base.connection.table_exists?("teacher_documents")
  ActiveRecord::Base.connection.execute("DELETE FROM teacher_documents")
end

# 5. Supprimer les teachers (dépend de users)
Teacher.destroy_all

# 6. Supprimer les users teachers
User.where(role: "teacher").destroy_all

puts "✅ Données nettoyées"

# Charger le fichier YAML
teachers_data = YAML.load_file(Rails.root.join('db', 'teachers.yml'))['teachers']

puts "Création de #{teachers_data.length} professeurs..."

teachers_data.each_with_index do |teacher_data, index|
  # Nettoyer les données
  levels = clean_levels(teacher_data['levels'])
  # Le YAML utilise 'subjects' mais le modèle utilise 'subjects_tags'
  subjects = clean_subjects(teacher_data['subjects'] || teacher_data['subjects_tags'] || [])
  exam_tags = clean_exam_tags(teacher_data['exam_tags'] || [])
  pedagogy_tags = clean_pedagogy_tags(teacher_data['pedagogy_tags'] || [])
  teaching_formats = clean_teaching_formats(teacher_data['teaching_formats'] || [])

  # Créer ou trouver l'utilisateur
  email_pro = teacher_data['email_pro']
  # Nettoyer l'email : enlever les espaces, null, etc.
  email_pro = email_pro.to_s.strip if email_pro
  email_pro = nil if email_pro.blank? || email_pro == "null"

  # Générer un email valide si nécessaire
  if email_pro.nil? || !email_pro.match?(URI::MailTo::EMAIL_REGEXP)
    email_pro = "teacher#{index}@example.com"
  end

  user = User.find_or_initialize_by(email: email_pro)

  if user.new_record?
    user.password = "password123"
    user.password_confirmation = "password123"
    user.role = "teacher"
    user.first_name = teacher_data['first_name']
    user.last_name = teacher_data['last_name']
    user.save!
  end

  # Créer ou mettre à jour le teacher
  teacher = Teacher.find_or_initialize_by(user: user)

  teacher.assign_attributes(
    first_name: teacher_data['first_name'] || "Prénom",
    last_name: teacher_data['last_name'] || "Nom",
    display_name: teacher_data['display_name'] || "#{teacher_data['first_name']} #{teacher_data['last_name']}",
    gender: teacher_data['gender'] || "female",
    academy_name: teacher_data['academy_name'],
    school_name: teacher_data['school_name'],
    career_status: teacher_data['career_status'] || "certifie",
    levels: levels,
    subjects_tags: subjects,
    teaching_formats: teaching_formats,
    address: teacher_data['address'] || teacher_data['base_address'],
    zip_code: teacher_data['zip_code'] || teacher_data['base_zip_code'],
    city: teacher_data['city'] || teacher_data['base_city'],
    radius_text: teacher_data['radius_text'],
    support_text: teacher_data['support_text'],
    experience_text: teacher_data['experience_text'],
    special_skills_text: teacher_data['special_skills_text'],
    interest_text: teacher_data['interest_text'],
    exams_raw_text: teacher_data['exams_raw_text'],
    exam_tags: exam_tags,
    pedagogy_tags: pedagogy_tags,
    pricing_text: teacher_data['pricing_text'],
    email_pro: email_pro,
    email_perso: teacher_data['email_perso'],
    phone: teacher_data['phone'],
    profile_image_url: random_photo_url(teacher_data['gender'] || "female", index),
    status: teacher_data['status'] || "pending",
    rgpd_consent: teacher_data['rgpd_consent'] || false,
    picture_visible: teacher_data['picture_visible'] || false
  )

  teacher.save!

  puts "✓ #{teacher.display_name} créé"
end

puts "\n✅ #{teachers_data.length} professeurs créés avec succès!"
