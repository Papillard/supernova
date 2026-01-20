# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'yaml'

# Helper pour obtenir une URL de photo placeholder
def random_photo_url(gender, index)
  seed = (index * 7) % 100
  if gender == "female"
    "https://i.pravatar.cc/300?img=#{seed + 20}"
  else
    "https://i.pravatar.cc/300?img=#{seed + 60}"
  end
end

# Helper pour normaliser les niveaux
def normalize_levels(levels)
  return [] if levels.nil?
  valid_levels = ["primaire", "college", "lycee", "prepa", "autre"]
  mapping = {
    "lycée" => "lycee",
    "collège" => "college",
    "prépa" => "prepa"
  }
  levels.map { |l| mapping[l.downcase] || l.downcase }.select { |l| valid_levels.include?(l) }.uniq
end

# Helper pour normaliser les matières (normalise tirets/underscores)
def normalize_subjects(subjects)
  return [] if subjects.nil?
  valid_subjects = TeachersHelper::SUBJECTS_OPTIONS.map { |_, v| v }
  subjects.map do |s|
    normalized = s.to_s.strip
    # Normaliser les variations courantes
    normalized = normalized.gsub("_", "-") if normalized.include?("_")
    # Chercher dans les valeurs valides
    valid_subjects.find { |_, v| v == normalized }&.last || normalized
  end.select { |s| valid_subjects.include?(s) }.uniq
end

# Helper pour normaliser les exam_tags
def normalize_exam_tags(tags)
  return [] if tags.nil?
  valid_tags = TeachersHelper::EXAM_TAGS_OPTIONS.map { |_, v| v }
  tags.map { |t| t.to_s.gsub("-", "_").strip }.select { |t| valid_tags.include?(t) }.uniq
end

# Helper pour normaliser les target_audience_tags
def normalize_target_audience_tags(tags)
  return [] if tags.nil?
  valid_tags = TeachersHelper::TARGET_AUDIENCE_TAGS_OPTIONS.map { |_, v| v }
  # Mapping des variations courantes
  mapping = {
    "methodologie" => "methodologie_organisation",
    "orientation" => "orientation_parcoursup"
  }
  tags.map do |t|
    normalized = t.to_s.gsub("-", "_").strip
    mapping[normalized] || normalized
  end.select { |t| valid_tags.include?(t) }.uniq
end

# Helper pour normaliser les specific_support
def normalize_specific_support(tags)
  return [] if tags.nil?
  valid_tags = TeachersHelper::SPECIFIC_SUPPORT_OPTIONS.map { |_, v| v }
  tags.map { |t| t.to_s.gsub("-", "_").strip }.select { |t| valid_tags.include?(t) }.uniq
end

# Helper pour normaliser les teaching_formats
def normalize_teaching_formats(formats)
  return [] if formats.nil?
  valid_formats = ["online", "at_student_home", "at_teacher_home"]
  formats.select { |f| valid_formats.include?(f) }
end

# Helper pour normaliser les served_zones
def normalize_served_zones(zones)
  return [] if zones.nil?
  # Extraire toutes les zones valides
  all_valid_zones = []
  TeachersHelper::SERVED_ZONES.each do |group_key, group_data|
    group_data[:items].each do |key, _|
      all_valid_zones << "#{group_key}:#{key}"
    end
  end

  # Filtrer pour ne garder que les zones valides
  zones.select { |zone| all_valid_zones.include?(zone.to_s) }
end

# Nettoyer les données existantes
puts "Nettoyage des données existantes..."

User.skip_callback(:commit, :after, :send_welcome_email)
Teacher.skip_callback(:after, :commit, :send_welcome_email_if_approved)

EmailEvent.destroy_all if defined?(EmailEvent)
Message.destroy_all
Request.destroy_all

if ActiveRecord::Base.connection.table_exists?("teacher_documents")
  ActiveRecord::Base.connection.execute("DELETE FROM teacher_documents")
end

Teacher.destroy_all
User.where(role: "teacher").destroy_all

puts "✅ Données nettoyées"

# Charger le fichier YAML
teachers_data = YAML.load_file(Rails.root.join('db', 'teachers.yml'))['teachers']

puts "📚 Chargement de #{teachers_data.length} professeurs depuis le fichier YAML..."

# Statistiques
stats = {
  created: 0,
  updated: 0,
  errors: 0,
  skipped: 0
}

teachers_data.each_with_index do |data, index|
  begin
    # Normaliser les données
    levels = normalize_levels(data['levels'])
    subjects = normalize_subjects(data['subjects'] || data['subjects_tags'] || [])
    exam_tags = normalize_exam_tags(data['exam_tags'] || [])
    target_audience_tags = normalize_target_audience_tags(data['target_audience_tags'] || [])
    specific_support = normalize_specific_support(data['specific_support'] || [])
    teaching_formats = normalize_teaching_formats(data['teaching_formats'] || [])
    served_zones = normalize_served_zones(data['served_zones'] || [])

    # Normaliser career_status
    career_status = case data['career_status'].to_s.downcase
    when "certifié", "certifie" then "certifie"
    when "agrégé", "agrege" then "agrege"
    when "prof_des_ecoles", "prof des écoles" then "prof_des_ecoles"
    else data['career_status'] || "certifie"
    end

    # Gérer l'email pro
    email_pro = data['email_pro'].to_s.strip
    email_pro = nil if email_pro.blank? || email_pro == "null"
    email_pro = "teacher#{index}@example.com" if email_pro.blank? || !email_pro.match?(URI::MailTo::EMAIL_REGEXP)

    # Créer ou trouver l'utilisateur
    user = User.find_or_initialize_by(email: email_pro)
    user_was_new = user.new_record?
    if user_was_new
      user.password = "password123"
      user.password_confirmation = "password123"
      user.role = "teacher"
      user.first_name = data['first_name']
      user.last_name = data['last_name']
      user.save!
    end

    # Créer ou mettre à jour le teacher
    teacher = Teacher.find_or_initialize_by(user: user)
    teacher_was_new = teacher.new_record?

    # Nettoyer le téléphone
    phone = data['phone'].to_s.gsub(/[^\d+]/, '').strip
    phone = nil if phone.blank?

    # Utiliser directement les valeurs du YAML
    teacher.assign_attributes(
      first_name: data['first_name'] || "Prénom",
      last_name: data['last_name'] || "Nom",
      display_name: data['display_name'] || "#{data['first_name']} #{data['last_name']}",
      gender: data['gender'] || "female",
      academy_name: data['academy_name'],
      school_name: data['school_name'],
      career_status: career_status,
      levels: levels,
      subjects_tags: subjects,
      teaching_formats: teaching_formats,
      zip_code: data['zip_code'] || data['base_zip_code'],
      city: data['city'] || data['base_city'],
      served_zones: served_zones,
      about_me: data['about_me']&.strip,
      headline: data['headline']&.strip,
      primary_subject: data['primary_subject'] || subjects.first || "mathematiques",
      specific_support: specific_support,
      target_audience_tags: target_audience_tags,
      exams_raw_text: data['exams_raw_text'],
      exam_tags: exam_tags,
      pricing_text: data['pricing_text'],
      target_students_range: data['target_students_range'],
      email_pro: email_pro,
      email_perso: data['email_perso'],
      phone: phone,
      profile_image_url: random_photo_url(data['gender'] || "female", index),
      status: data['status'] || "pending",
      rgpd_consent: data['rgpd_consent'] || false,
      accepted_requests_count: 0
    )

    teacher.save!
    
    if teacher_was_new
      stats[:created] += 1
      puts "✓ [#{index + 1}/#{teachers_data.length}] Créé: #{teacher.display_name}"
    else
      stats[:updated] += 1
      puts "↻ [#{index + 1}/#{teachers_data.length}] Mis à jour: #{teacher.display_name}"
    end
  rescue => e
    stats[:errors] += 1
    puts "✗ [#{index + 1}/#{teachers_data.length}] ERREUR pour #{data['first_name']} #{data['last_name']}: #{e.message}"
    puts "   #{e.backtrace.first(3).join("\n   ")}"
  end
end

User.set_callback(:commit, :after, :send_welcome_email)
Teacher.set_callback(:after, :commit, :send_welcome_email_if_approved)

puts "\n" + "="*60
puts "✅ Traitement terminé!"
puts "   📊 Statistiques:"
puts "   • Créés: #{stats[:created]}"
puts "   • Mis à jour: #{stats[:updated]}"
puts "   • Erreurs: #{stats[:errors]}"
puts "   • Total traité: #{stats[:created] + stats[:updated]} / #{teachers_data.length}"
puts "="*60
