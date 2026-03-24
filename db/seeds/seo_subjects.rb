puts "Seeding SEO subjects..."

SUBJECTS = [
  { name: "Mathematiques", slug: "maths", tag_code: "mathematiques", display_name: "Mathematiques", category: "Fondamentaux" },
  { name: "Francais", slug: "francais", tag_code: "francais", display_name: "Francais", category: "Fondamentaux" },
  { name: "Anglais", slug: "anglais", tag_code: "anglais", display_name: "Anglais", category: "Fondamentaux" },
  { name: "Physique-Chimie", slug: "physique-chimie", tag_code: "physique-chimie", display_name: "Physique-Chimie", category: "Sciences" },
  { name: "SVT", slug: "svt", tag_code: "svt", display_name: "SVT", category: "Sciences" },
  { name: "Histoire-Geographie", slug: "histoire-geographie", tag_code: "histoire-geographie", display_name: "Histoire-Geographie", category: "Sciences humaines & lettres" },
  { name: "Espagnol", slug: "espagnol", tag_code: "espagnol", display_name: "Espagnol", category: "Langues" },
  { name: "Allemand", slug: "allemand", tag_code: "allemand", display_name: "Allemand", category: "Langues" },
  { name: "Philosophie", slug: "philosophie", tag_code: "philosophie", display_name: "Philosophie", category: "Sciences humaines & lettres" },
  { name: "SES", slug: "ses", tag_code: "ses", display_name: "SES", category: "Sciences humaines & lettres" },
  { name: "NSI", slug: "nsi", tag_code: "nsi", display_name: "NSI", category: "Sciences" },
  { name: "Aide aux devoirs", slug: "aide-aux-devoirs", tag_code: "aide_aux_devoirs", display_name: "Aide aux devoirs", category: "Fondamentaux" },
  { name: "Lecture / Ecriture", slug: "lecture-ecriture", tag_code: "lecture_ecriture", display_name: "Lecture / Ecriture", category: "Fondamentaux" },
  { name: "Informatique", slug: "informatique", tag_code: "informatique", display_name: "Informatique", category: "Economie / Sup / Pro" },
  { name: "Italien", slug: "italien", tag_code: "italien", display_name: "Italien", category: "Langues" },
  { name: "Economie", slug: "economie", tag_code: "economie", display_name: "Economie", category: "Economie / Sup / Pro" },
  { name: "HGGSP", slug: "hggsp", tag_code: "hggsp", display_name: "HGGSP", category: "Sciences humaines & lettres" },
  { name: "Litterature", slug: "litterature", tag_code: "litterature", display_name: "Litterature", category: "Sciences humaines & lettres" },
  { name: "Latin", slug: "latin", tag_code: "latin", display_name: "Latin", category: "Langues" },
  { name: "Droit", slug: "droit", tag_code: "droit", display_name: "Droit", category: "Economie / Sup / Pro" }
].freeze

SUBJECTS.each_with_index do |attrs, index|
  Subject.find_or_create_by!(slug: attrs[:slug]) do |s|
    s.name = attrs[:name]
    s.tag_code = attrs[:tag_code]
    s.display_name = attrs[:display_name]
    s.category = attrs[:category]
    s.position = index
  end
end

puts "  #{Subject.count} subjects seeded"
