namespace :teachers do
  desc "Create test teacher boris in pending status"
  task create_test_teacher: :environment do
    # Désactiver temporairement le callback pour éviter les emails
    User.skip_callback(:commit, :after, :send_welcome_email)

    email_pro = "boris@lewagon.org"
    email_perso = "boris.paillard@gmail.com"

    # Créer User placeholder avec email_pro
    user = User.find_or_initialize_by(email: email_pro)
    if user.new_record?
      user.role = "teacher"
      user.password = SecureRandom.hex(64) # Mot de passe invalide
      user.password_confirmation = user.password
      user.first_name = "Boris"
      user.last_name = "Paillard"
      user.save!
      puts "✅ User créé: #{email_pro}"
    else
      puts "⚠️  User existe déjà: #{email_pro}"
    end

    # Créer Teacher en pending
    teacher = Teacher.find_or_initialize_by(user: user)
    teacher.assign_attributes(
      first_name: "Boris",
      last_name: "Paillard",
      display_name: "Boris P.",
      gender: :male,
      academy_name: "Paris",
      school_name: "Le Wagon",
      career_status: :certifie,
      levels: ["college", "lycee"],
      subjects_tags: ["mathematiques", "informatique"],
      teaching_formats: ["at_student_home", "online"],
      pricing_text: "60 €",
      city: "Paris",
      zip_code: "75011",
      served_zones: ["Paris"],
      support_text: "Cours de mathématiques et programmation pour collège et lycée.",
      experience_text: "Enseignant au Wagon depuis 2015.",
      special_skills_text: "Spécialisé en programmation et mathématiques appliquées.",
      email_pro: email_pro,
      email_perso: email_perso,
      phone: "+33612345678",
      status: :pending,  # ⚠️ Important : en pending
      rgpd_consent: true,
      picture_visible: false
    )

    if teacher.save!
      puts "✅ Teacher créé en pending: #{teacher.display_name}"
      puts "   Status: #{teacher.status}"
      puts "   RGPD consent: #{teacher.rgpd_consent}"
    else
      puts "❌ Erreur: #{teacher.errors.full_messages.join(', ')}"
    end

    # Réactiver le callback
    User.set_callback(:commit, :after, :send_welcome_email)

    puts "\n🎉 Test teacher créé !"
    puts "   Email pro: #{email_pro}"
    puts "   Email perso: #{email_perso}"
    puts "   Teacher ID: #{teacher.id}"
    puts "   User ID: #{user.id}"
    puts "\n💡 Le teacher peut s'inscrire avec #{email_pro} OU #{email_perso}"
  end
end
