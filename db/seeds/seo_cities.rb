puts "Seeding SEO cities..."

CITIES = [
  # Paris arrondissements (75)
  { name: "Paris 1er", slug: "paris-1er", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 2e", slug: "paris-2e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 3e", slug: "paris-3e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 4e", slug: "paris-4e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 5e", slug: "paris-5e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 6e", slug: "paris-6e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 7e", slug: "paris-7e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 8e", slug: "paris-8e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 9e", slug: "paris-9e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 10e", slug: "paris-10e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 11e", slug: "paris-11e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 12e", slug: "paris-12e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 13e", slug: "paris-13e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 14e", slug: "paris-14e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 15e", slug: "paris-15e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 16e", slug: "paris-16e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 17e", slug: "paris-17e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 18e", slug: "paris-18e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 19e", slug: "paris-19e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },
  { name: "Paris 20e", slug: "paris-20e", department_code: "75", served_zone_codes: ["ile_de_france:paris"], parent_city: "Paris", population_tier: 3 },

  # 92 - Hauts-de-Seine
  { name: "Boulogne-Billancourt", slug: "boulogne-billancourt", department_code: "92", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 3 },
  { name: "Neuilly-sur-Seine", slug: "neuilly-sur-seine", department_code: "92", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 2 },
  { name: "Levallois-Perret", slug: "levallois-perret", department_code: "92", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 2 },
  { name: "Issy-les-Moulineaux", slug: "issy-les-moulineaux", department_code: "92", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 2 },
  { name: "Courbevoie", slug: "courbevoie", department_code: "92", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 2 },
  { name: "Rueil-Malmaison", slug: "rueil-malmaison", department_code: "92", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 2 },
  { name: "Saint-Cloud", slug: "saint-cloud", department_code: "92", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 2 },

  # 78 - Yvelines
  { name: "Versailles", slug: "versailles", department_code: "78", served_zone_codes: ["ile_de_france:grande_couronne"], population_tier: 2 },
  { name: "Saint-Germain-en-Laye", slug: "saint-germain-en-laye", department_code: "78", served_zone_codes: ["ile_de_france:grande_couronne"], population_tier: 2 },
  { name: "Le Vesinet", slug: "le-vesinet", department_code: "78", served_zone_codes: ["ile_de_france:grande_couronne"], population_tier: 1 },
  { name: "Maisons-Laffitte", slug: "maisons-laffitte", department_code: "78", served_zone_codes: ["ile_de_france:grande_couronne"], population_tier: 1 },

  # 94 - Val-de-Marne
  { name: "Vincennes", slug: "vincennes", department_code: "94", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 2 },
  { name: "Creteil", slug: "creteil", department_code: "94", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 2 },
  { name: "Saint-Mande", slug: "saint-mande", department_code: "94", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 1 },
  { name: "Nogent-sur-Marne", slug: "nogent-sur-marne", department_code: "94", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 1 },
  { name: "Charenton-le-Pont", slug: "charenton-le-pont", department_code: "94", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 1 },

  # 91 - Essonne
  { name: "Massy", slug: "massy", department_code: "91", served_zone_codes: ["ile_de_france:grande_couronne"], population_tier: 2 },
  { name: "Evry-Courcouronnes", slug: "evry-courcouronnes", department_code: "91", served_zone_codes: ["ile_de_france:grande_couronne"], population_tier: 2 },
  { name: "Palaiseau", slug: "palaiseau", department_code: "91", served_zone_codes: ["ile_de_france:grande_couronne"], population_tier: 1 },

  # 93 - Seine-Saint-Denis
  { name: "Montreuil", slug: "montreuil", department_code: "93", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 3 },
  { name: "Saint-Denis", slug: "saint-denis", department_code: "93", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 3 },
  { name: "Pantin", slug: "pantin", department_code: "93", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 2 },
  { name: "Le Raincy", slug: "le-raincy", department_code: "93", served_zone_codes: ["ile_de_france:petite_couronne"], population_tier: 1 },

  # 95 - Val-d'Oise
  { name: "Enghien-les-Bains", slug: "enghien-les-bains", department_code: "95", served_zone_codes: ["ile_de_france:grande_couronne"], population_tier: 1 },
  { name: "Cergy", slug: "cergy", department_code: "95", served_zone_codes: ["ile_de_france:grande_couronne"], population_tier: 2 }
].freeze

CITIES.each do |attrs|
  City.find_or_create_by!(slug: attrs[:slug]) do |c|
    c.name = attrs[:name]
    c.department_code = attrs[:department_code]
    c.served_zone_codes = attrs[:served_zone_codes] || []
    c.parent_city = attrs[:parent_city]
    c.population_tier = attrs[:population_tier] || 1
  end
end

puts "  #{City.count} cities seeded"
