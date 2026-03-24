puts "Seeding SEO pages..."

subjects = Subject.all
cities = City.all

count = 0

subjects.each do |subject|
  cities.each do |city|
    slug = "#{subject.slug}/#{city.slug}"
    page = SeoPage.find_or_initialize_by(subject: subject, city: city)

    if page.new_record?
      page.slug = slug
      page.page_type = "subject_city"
      page.h1 = "Cours particuliers de #{subject.display_name} a #{city.name}"
      page.meta_title = "Cours de #{subject.display_name} a #{city.name} | ProfConnect"
      page.meta_description = "Trouvez un professeur certifie de l'Education Nationale pour des cours particuliers de #{subject.display_name} a #{city.name}. Professeurs verifies, accompagnement personnalise."
      page.published = true
      page.save!

      # Placeholder content blocks
      SeoContent.find_or_create_by!(seo_page: page, block_type: "intro") do |c|
        c.position = 0
        c.content = "Vous recherchez un professeur de #{subject.display_name} a #{city.name} ? ProfConnect vous met en relation avec des enseignants certifies de l'Education Nationale pour des cours particuliers adaptes au niveau de votre enfant."
      end

      SeoContent.find_or_create_by!(seo_page: page, block_type: "why_us") do |c|
        c.position = 0
        c.content = "Tous nos professeurs sont des enseignants certifies de l'Education Nationale. Ils connaissent les programmes officiels et savent exactement comment accompagner votre enfant vers la reussite. Pas d'etudiants, pas d'auto-proclames : uniquement de vrais professeurs."
      end

      SeoContent.find_or_create_by!(seo_page: page, block_type: "how_it_works") do |c|
        c.position = 0
        c.content = "1. Choisissez un professeur\n2. Envoyez une demande\n3. Demarrez les cours"
      end

      # FAQ items
      [
        "Combien coute un cours de #{subject.display_name} a #{city.name} ?\nLes tarifs varient selon le professeur et le niveau. Consultez les profils pour voir les tarifs de chaque enseignant.",
        "Comment sont selectionnes les professeurs ?\nTous nos professeurs sont des enseignants certifies de l'Education Nationale. Leur profil est verifie par notre equipe avant publication.",
        "Les cours peuvent-ils avoir lieu en ligne ?\nOui, de nombreux professeurs proposent des cours en ligne en plus des cours a domicile. Verifiez les modalites sur le profil de chaque enseignant.",
        "Mon enfant peut-il avoir un premier cours d'essai ?\nCela depend du professeur. Nous vous recommandons de le mentionner dans votre demande de cours."
      ].each_with_index do |faq_text, i|
        SeoContent.find_or_create_by!(seo_page: page, block_type: "faq", position: i) do |c|
          c.content = faq_text
        end
      end

      count += 1
    end
  end
end

puts "  #{count} subject_city pages created (#{SeoPage.count} total)"
