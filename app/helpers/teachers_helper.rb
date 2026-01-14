module TeachersHelper
  # Niveaux disponibles (par ordre d'importance)
  LEVELS_OPTIONS = [
    ["Primaire", "primaire"],
    ["Collège", "college"],
    ["Lycée", "lycee"],
    ["Prépa et Supérieur", "prepa"],
    ["Autre", "autre"]
  ].freeze

  # Villes disponibles
  CITIES_OPTIONS = [
    ["Toutes les villes", ""],
    ["Paris", "Paris"],
    ["Versailles", "Versailles"],
    ["Nîmes", "Nîmes"],
    ["Dax", "Dax"]
  ].freeze

  # Matières disponibles (liste unique sans groupement)
  SUBJECTS_OPTIONS = [
    ["Aide aux devoirs", "aide_aux_devoirs"],
    ["Mathématiques", "mathematiques"],
    ["Français", "francais"],
    ["Anglais", "anglais"],
    ["Espagnol", "espagnol"],
    ["Allemand", "allemand"],
    ["Italien", "italien"],
    ["Physique-Chimie", "physique-chimie"],
    ["SVT", "svt"],
    ["Histoire-Géographie", "histoire-geographie"],
    ["HGGSP", "hggsp"],
    ["SES", "ses"],
    ["EMC", "emc"],
    ["Technologie", "technologie"],
    ["SNT", "snt"],
    ["NSI", "nsi"],
    ["Lecture / Écriture", "lecture_ecriture"],
    ["Philosophie", "philosophie"],
    ["Littérature", "litterature"],
    ["Géopolitique", "geopolitique"],
    ["HLP", "hlp"],
    ["Économie", "economie"],
    ["Sciences politiques", "sciences_politiques"],
    ["Droit", "droit"],
    ["Comptabilité & Gestion", "comptabilite_gestion"],
    ["Finance", "finance"],
    ["Marketing", "marketing"],
    ["Psychologie", "psychologie"],
    ["Informatique", "informatique"]
  ].freeze

  # Tags examens disponibles (par ordre d'importance)
  EXAM_TAGS_OPTIONS = [
    ["Brevet", "brevet"],
    ["Bac général", "bac_general"],
    ["Bac techno", "bac_techno"],
    ["Bac pro", "bac_pro"],
    ["Concours IEP / Sciences Po", "concours_ieP_sciences_po"],
    ["Concours école de commerce", "concours_ecole_commerce"],
    ["Concours paramédical", "concours_paramedical"],
    ["Parcoursup", "parcoursup"],
    ["TOEIC", "toeic"],
    ["IELTS", "ielts"],
    ["Cambridge", "cambridge"]
  ].freeze

  # Options de rayon de déplacement disponibles
  RADIUS_OPTIONS = [
    ["Moins de 1 km", "moins_de_1_km"],
    ["2 à 5 km", "deux_a_5_km"],
    ["5 à 10 km", "5_a_10_km"],
    ["10 à 20 km", "10_a_20_km"],
    ["Plus de 20 km", "plus_de_20_km"]
  ].freeze

  # Tags pédagogie disponibles (par ordre d'importance)
  PEDAGOGY_TAGS_OPTIONS = [
    ["Aide aux devoirs", "aide_aux_devoirs"],
    ["Remise à niveau", "remise_a_niveau"],
    ["Méthodologie de travail", "methodologie_travail"],
    ["Méthodologie", "methodologie"],
    ["Besoins particuliers", "besoins_particuliers"],
    ["Organisation", "organisation"],
    ["Préparation examens", "preparation_examens"],
    ["Élèves en difficulté", "eleves_en_difficulte"],
    ["Haut potentiel", "haut_potentiel"],
    ["Confiance en soi", "confiance_en_soi"],
    ["Orientation", "orientation"],
    ["Parcoursup", "parcoursup"],
    ["FLE", "fle"],
    ["Élèves TDAH", "eleves_tdah"],
    ["Élèves à troubles DYS", "eleves_troubles_dys"]
  ].freeze

  # Helper pour obtenir les initiales d'un professeur
  def teacher_initials(teacher)
    first_initial = teacher.first_name.present? ? teacher.first_name[0].upcase : ""
    last_initial = teacher.last_name.present? ? teacher.last_name[0].upcase : ""
    "#{first_initial}#{last_initial}"
  end

  # Helper pour obtenir le nom d'affichage court (Prénom Initiale)
  def teacher_short_name(teacher)
    if teacher.first_name.present? && teacher.last_name.present?
      "#{teacher.first_name} #{teacher.last_name[0].upcase}."
    elsif teacher.first_name.present?
      teacher.first_name
    else
      "Professeur"
    end
  end

  # Helper pour formater l'affichage d'une matière (acronymes en majuscule)
  def format_subject_tag(tag)
    # Chercher le label correspondant dans SUBJECTS_OPTIONS
    subject_option = SUBJECTS_OPTIONS.find { |_, value| value == tag }
    if subject_option
      subject_option[0] # Retourner le label (déjà formaté avec majuscules pour acronymes)
    else
      tag.humanize # Fallback si la matière n'est pas trouvée
    end
  end

  # Helper pour formater l'affichage d'un niveau
  def format_level_tag(level)
    # Chercher le label correspondant dans LEVELS_OPTIONS
    level_option = LEVELS_OPTIONS.find { |_, value| value == level }
    if level_option
      level_option[0] # Retourner le label
    else
      level.humanize # Fallback si le niveau n'est pas trouvé
    end
  end

  # Helper pour formater le rayon d'intervention de manière humaine
  def format_radius_human(radius_text)
    return "" if radius_text.blank?

    # Mapping des valeurs courantes (inclut variantes possibles)
    radius_mapping = {
      "moins_de_1_km" => "Se déplace de moins de 1 km",
      "deux_a_5_km" => "Se déplace de 2 à 5 km",
      "2_a_5_km" => "Se déplace de 2 à 5 km",
      "5_a_10_km" => "Se déplace de 5 à 10 km",
      "cinq_a_10_km" => "Se déplace de 5 à 10 km",
      "cinq_a_dix_km" => "Se déplace de 5 à 10 km",
      "10_a_20_km" => "Se déplace de 10 à 20 km",
      "dix_a_20_km" => "Se déplace de 10 à 20 km",
      "dix_a_vingt_km" => "Se déplace de 10 à 20 km",
      "plus_de_20_km" => "Se déplace de plus de 20 km",
      "plus_de_vingt_km" => "Se déplace de plus de 20 km"
    }

    # Vérifier si c'est une valeur mappée
    if radius_mapping.key?(radius_text.downcase)
      return radius_mapping[radius_text.downcase]
    end

    # Chercher dans RADIUS_OPTIONS pour le label correspondant
    radius_option = RADIUS_OPTIONS.find { |_, value| value == radius_text }
    if radius_option
      return "Se déplace de #{radius_option[0].downcase}"
    end

    # Si le texte contient déjà "km", on ajoute "Se déplace de" au début
    if radius_text.downcase.include?("km")
      return "Se déplace de #{radius_text}"
    end

    # Sinon, on essaie d'extraire un nombre et on ajoute "Se déplace de" et "km"
    if radius_text.match?(/\d+/)
      number = radius_text.scan(/\d+/).first
      "Se déplace de #{number} km"
    else
      "Se déplace de #{radius_text.humanize}"
    end
  end

  # Helper pour formater les formats d'enseignement en français
  def format_teaching_format(format)
    format_mapping = {
      "at_student_home" => "Au domicile de l'élève",
      "at_teacher_home" => "Au domicile du professeur",
      "online" => "En ligne"
    }

    format_mapping[format.to_s] || format.humanize
  end

  # Helper pour formater plusieurs formats d'enseignement
  def format_teaching_formats(formats)
    return "" if formats.blank?
    formats.map { |f| format_teaching_format(f) }.join(", ")
  end

  # Helper pour générer une phrase naturelle sur les formats de cours
  def format_teaching_formats_sentence(formats, teacher_gender = nil)
    return "" if formats.blank?

    formats_array = formats.is_a?(Array) ? formats : [formats]
    formats_array = formats_array.compact.uniq

    case formats_array.length
    when 1
      format = formats_array.first
      case format.to_s
      when "online"
        "Je donne des cours uniquement en ligne."
      when "at_teacher_home"
        "Je donne des cours chez moi uniquement."
      when "at_student_home"
        "Je me déplace au domicile de l'élève uniquement."
      else
        "Je donne des cours #{format_teaching_format(format).downcase}."
      end
    when 2
      has_online = formats_array.include?("online")
      has_student_home = formats_array.include?("at_student_home")
      has_teacher_home = formats_array.include?("at_teacher_home")

      if has_student_home && has_teacher_home
        "Je peux donner des cours au domicile de l'élève ou chez moi."
      elsif has_student_home && has_online
        "Je peux donner des cours en ligne ou au domicile de l'élève."
      elsif has_teacher_home && has_online
        "Je peux donner des cours en ligne ou chez moi."
      else
        "Je peux donner des cours #{formats_array.map { |f| format_teaching_format(f).downcase }.join(' ou ')}."
      end
    when 3
      "Je peux donner des cours en ligne, au domicile de l'élève ou chez moi."
    else
      # Fallback pour plus de 3 formats
      "Je peux donner des cours #{formats_array.first(3).map { |f| format_teaching_format(f).downcase }.join(', ')}."
    end
  end

  # Helper pour formater un tag d'examen
  def format_exam_tag(tag)
    exam_option = EXAM_TAGS_OPTIONS.find { |_, value| value == tag }
    if exam_option
      exam_option[0]
    else
      tag.humanize
    end
  end

  # Version courte pour les cards
  EXAM_TAGS_SHORT = {
    "concours_ieP_sciences_po" => "Sciences Po",
    "concours_ecole_commerce" => "École commerce"
  }.freeze

  def format_exam_tag_short(tag)
    EXAM_TAGS_SHORT[tag] || format_exam_tag(tag)
  end

  # Helper pour formater un tag pédagogique
  def format_pedagogy_tag(tag)
    pedagogy_option = PEDAGOGY_TAGS_OPTIONS.find { |_, value| value == tag }
    if pedagogy_option
      pedagogy_option[0]
    else
      tag.humanize
    end
  end

  # Version courte pour les cards
  PEDAGOGY_TAGS_SHORT = {
    "methodologie_travail" => "Méthodologie",
    "preparation_examens" => "Prépa examens",
    "eleves_en_difficulte" => "Élèves en difficulté",
    "besoins_particuliers" => "Besoins particuliers"
  }.freeze

  def format_pedagogy_tag_short(tag)
    PEDAGOGY_TAGS_SHORT[tag] || format_pedagogy_tag(tag)
  end

  # Helper pour formater le texte des tarifs (ajoute "/ heure" si absent)
  def format_pricing_text(pricing_text)
    return "" if pricing_text.blank?

    # Si le texte contient déjà "/ heure" ou "par heure" ou "heure", on le retourne tel quel
    return pricing_text if pricing_text.downcase.match?(/(\/\s*heure|par\s+heure|heure)/)

    # Sinon, on ajoute "/ heure" à la fin
    "#{pricing_text} / heure"
  end

  # Helper pour formater le statut de carrière avec les accents corrects
  def format_career_status(career_status)
    return "" if career_status.blank?

    # Convertir en string
    value = career_status.is_a?(String) ? career_status : career_status.to_s

    # Mapping pour gérer les cas avec et sans accent (au cas où les données en DB varient)
    mapping = {
      # Valeurs avec accent (valeurs normales de l'enum)
      "certifié" => "Certifié",
      "agrégé" => "Agrégé",
      "prof des écoles" => "Prof des écoles",
      "autre" => "Autre",
      # Valeurs sans accent (cas de données anciennes ou clés)
      "certifie" => "Certifié",
      "agrege" => "Agrégé",
      "prof_des_ecoles" => "Prof des écoles"
    }

    # Chercher dans le mapping (insensible à la casse)
    result = mapping[value] || mapping[value.downcase]

    # Si trouvé, retourner le résultat
    return result if result

    # Sinon, capitaliser la première lettre
    value.capitalize
  end

  # Helper pour formater la localisation de manière naturelle
  def format_location_text(teacher)
    parts = []

    # Ville et code postal
    if teacher.city.present?
      location_str = teacher.city
      if teacher.zip_code.present?
        location_str += " (#{teacher.zip_code})"
      end
      parts << "Habite à #{location_str}"
    elsif teacher.zip_code.present?
      parts << "📍 #{teacher.zip_code}"
    end

    # Zones desservies
    if teacher.served_zones.present? && teacher.served_zones.any?
      zones_labels = teacher.served_zones.map do |zone_value|
        zone = all_served_zones_for_search.find { |z| z[:value] == zone_value }
        zone ? zone[:label] : zone_value
      end
      parts << "Zones desservies : #{zones_labels.join(', ')}"
    end

    parts.join(", ")
  end

  # Zones desservies - Structure avec regroupements
  SERVED_ZONES = {
    # Île-de-France (affiché au chargement)
    "ile_de_france" => {
      label: "Île-de-France",
      items: {
        "paris" => { label: "Paris", code: "75", type: "city" },
        "petite_couronne" => { label: "Petite couronne (92, 93, 94)", codes: ["92", "93", "94"], type: "area" },
        "grande_couronne" => { label: "Grande couronne (77, 78, 91, 95)", codes: ["77", "78", "91", "95"], type: "area" }
      }
    },
    # Grandes villes (affichées au chargement)
    "grandes_villes" => {
      label: "Grandes villes",
      items: {
        "lyon" => { label: "Lyon", code: "69", type: "city" },
        "marseille" => { label: "Marseille", code: "13", type: "city" },
        "lille" => { label: "Lille", code: "59", type: "city" },
        "toulouse" => { label: "Toulouse", code: "31", type: "city" },
        "bordeaux" => { label: "Bordeaux", code: "33", type: "city" },
        "nantes" => { label: "Nantes", code: "44", type: "city" },
        "rennes" => { label: "Rennes", code: "35", type: "city" },
        "strasbourg" => { label: "Strasbourg", code: "67", type: "city" },
        "montpellier" => { label: "Montpellier", code: "34", type: "city" },
        "nice" => { label: "Nice", code: "06", type: "city" },
        "grenoble" => { label: "Grenoble", code: "38", type: "city" },
        "rouen" => { label: "Rouen", code: "76", type: "city" },
        "reims" => { label: "Reims", code: "51", type: "city" },
        "toulon" => { label: "Toulon", code: "83", type: "city" },
        "saint_etienne" => { label: "Saint-Étienne", code: "42", type: "city" },
        "tours" => { label: "Tours", code: "37", type: "city" },
        "clermont_ferrand" => { label: "Clermont-Ferrand", code: "63", type: "city" },
        "nancy_metz" => { label: "Nancy / Metz", codes: ["54", "57"], type: "area" },
        "dijon" => { label: "Dijon", code: "21", type: "city" },
        "angers" => { label: "Angers", code: "49", type: "city" }
      }
    },
    # Départements (affichés uniquement lors de la recherche)
    "departements" => {
      label: "Départements",
      items: {
        "01" => { label: "Ain (01)", code: "01", type: "department" },
        "02" => { label: "Aisne (02)", code: "02", type: "department" },
        "03" => { label: "Allier (03)", code: "03", type: "department" },
        "04" => { label: "Alpes-de-Haute-Provence (04)", code: "04", type: "department" },
        "05" => { label: "Hautes-Alpes (05)", code: "05", type: "department" },
        "06" => { label: "Alpes-Maritimes (06)", code: "06", type: "department" },
        "07" => { label: "Ardèche (07)", code: "07", type: "department" },
        "08" => { label: "Ardennes (08)", code: "08", type: "department" },
        "09" => { label: "Ariège (09)", code: "09", type: "department" },
        "10" => { label: "Aube (10)", code: "10", type: "department" },
        "11" => { label: "Aude (11)", code: "11", type: "department" },
        "12" => { label: "Aveyron (12)", code: "12", type: "department" },
        "13" => { label: "Bouches-du-Rhône (13)", code: "13", type: "department" },
        "14" => { label: "Calvados (14)", code: "14", type: "department" },
        "15" => { label: "Cantal (15)", code: "15", type: "department" },
        "16" => { label: "Charente (16)", code: "16", type: "department" },
        "17" => { label: "Charente-Maritime (17)", code: "17", type: "department" },
        "18" => { label: "Cher (18)", code: "18", type: "department" },
        "19" => { label: "Corrèze (19)", code: "19", type: "department" },
        "2A" => { label: "Corse-du-Sud (2A)", code: "2A", type: "department" },
        "2B" => { label: "Haute-Corse (2B)", code: "2B", type: "department" },
        "21" => { label: "Côte-d'Or (21)", code: "21", type: "department" },
        "22" => { label: "Côtes-d'Armor (22)", code: "22", type: "department" },
        "23" => { label: "Creuse (23)", code: "23", type: "department" },
        "24" => { label: "Dordogne (24)", code: "24", type: "department" },
        "25" => { label: "Doubs (25)", code: "25", type: "department" },
        "26" => { label: "Drôme (26)", code: "26", type: "department" },
        "27" => { label: "Eure (27)", code: "27", type: "department" },
        "28" => { label: "Eure-et-Loir (28)", code: "28", type: "department" },
        "29" => { label: "Finistère (29)", code: "29", type: "department" },
        "30" => { label: "Gard (30)", code: "30", type: "department" },
        "31" => { label: "Haute-Garonne (31)", code: "31", type: "department" },
        "32" => { label: "Gers (32)", code: "32", type: "department" },
        "33" => { label: "Gironde (33)", code: "33", type: "department" },
        "34" => { label: "Hérault (34)", code: "34", type: "department" },
        "35" => { label: "Ille-et-Vilaine (35)", code: "35", type: "department" },
        "36" => { label: "Indre (36)", code: "36", type: "department" },
        "37" => { label: "Indre-et-Loire (37)", code: "37", type: "department" },
        "38" => { label: "Isère (38)", code: "38", type: "department" },
        "39" => { label: "Jura (39)", code: "39", type: "department" },
        "40" => { label: "Landes (40)", code: "40", type: "department" },
        "41" => { label: "Loir-et-Cher (41)", code: "41", type: "department" },
        "42" => { label: "Loire (42)", code: "42", type: "department" },
        "43" => { label: "Haute-Loire (43)", code: "43", type: "department" },
        "44" => { label: "Loire-Atlantique (44)", code: "44", type: "department" },
        "45" => { label: "Loiret (45)", code: "45", type: "department" },
        "46" => { label: "Lot (46)", code: "46", type: "department" },
        "47" => { label: "Lot-et-Garonne (47)", code: "47", type: "department" },
        "48" => { label: "Lozère (48)", code: "48", type: "department" },
        "49" => { label: "Maine-et-Loire (49)", code: "49", type: "department" },
        "50" => { label: "Manche (50)", code: "50", type: "department" },
        "51" => { label: "Marne (51)", code: "51", type: "department" },
        "52" => { label: "Haute-Marne (52)", code: "52", type: "department" },
        "53" => { label: "Mayenne (53)", code: "53", type: "department" },
        "54" => { label: "Meurthe-et-Moselle (54)", code: "54", type: "department" },
        "55" => { label: "Meuse (55)", code: "55", type: "department" },
        "56" => { label: "Morbihan (56)", code: "56", type: "department" },
        "57" => { label: "Moselle (57)", code: "57", type: "department" },
        "58" => { label: "Nièvre (58)", code: "58", type: "department" },
        "59" => { label: "Nord (59)", code: "59", type: "department" },
        "60" => { label: "Oise (60)", code: "60", type: "department" },
        "61" => { label: "Orne (61)", code: "61", type: "department" },
        "62" => { label: "Pas-de-Calais (62)", code: "62", type: "department" },
        "63" => { label: "Puy-de-Dôme (63)", code: "63", type: "department" },
        "64" => { label: "Pyrénées-Atlantiques (64)", code: "64", type: "department" },
        "65" => { label: "Hautes-Pyrénées (65)", code: "65", type: "department" },
        "66" => { label: "Pyrénées-Orientales (66)", code: "66", type: "department" },
        "67" => { label: "Bas-Rhin (67)", code: "67", type: "department" },
        "68" => { label: "Haut-Rhin (68)", code: "68", type: "department" },
        "69" => { label: "Rhône (69)", code: "69", type: "department" },
        "70" => { label: "Haute-Saône (70)", code: "70", type: "department" },
        "71" => { label: "Saône-et-Loire (71)", code: "71", type: "department" },
        "72" => { label: "Sarthe (72)", code: "72", type: "department" },
        "73" => { label: "Savoie (73)", code: "73", type: "department" },
        "74" => { label: "Haute-Savoie (74)", code: "74", type: "department" },
        "75" => { label: "Paris (75)", code: "75", type: "department" },
        "76" => { label: "Seine-Maritime (76)", code: "76", type: "department" },
        "77" => { label: "Seine-et-Marne (77)", code: "77", type: "department" },
        "78" => { label: "Yvelines (78)", code: "78", type: "department" },
        "79" => { label: "Deux-Sèvres (79)", code: "79", type: "department" },
        "80" => { label: "Somme (80)", code: "80", type: "department" },
        "81" => { label: "Tarn (81)", code: "81", type: "department" },
        "82" => { label: "Tarn-et-Garonne (82)", code: "82", type: "department" },
        "83" => { label: "Var (83)", code: "83", type: "department" },
        "84" => { label: "Vaucluse (84)", code: "84", type: "department" },
        "85" => { label: "Vendée (85)", code: "85", type: "department" },
        "86" => { label: "Vienne (86)", code: "86", type: "department" },
        "87" => { label: "Haute-Vienne (87)", code: "87", type: "department" },
        "88" => { label: "Vosges (88)", code: "88", type: "department" },
        "89" => { label: "Yonne (89)", code: "89", type: "department" },
        "90" => { label: "Territoire de Belfort (90)", code: "90", type: "department" },
        "91" => { label: "Essonne (91)", code: "91", type: "department" },
        "92" => { label: "Hauts-de-Seine (92)", code: "92", type: "department" },
        "93" => { label: "Seine-Saint-Denis (93)", code: "93", type: "department" },
        "94" => { label: "Val-de-Marne (94)", code: "94", type: "department" },
        "95" => { label: "Val-d'Oise (95)", code: "95", type: "department" }
      }
    },
    # Outre-mer (affichés uniquement lors de la recherche)
    "outre_mer" => {
      label: "Outre-mer",
      items: {
        "971" => { label: "Guadeloupe (971)", code: "971", type: "department" },
        "972" => { label: "Martinique (972)", code: "972", type: "department" },
        "973" => { label: "Guyane (973)", code: "973", type: "department" },
        "974" => { label: "La Réunion (974)", code: "974", type: "department" },
        "976" => { label: "Mayotte (976)", code: "976", type: "department" }
      }
    }
  }.freeze

  # Helper pour obtenir toutes les zones sous forme de liste plate pour la recherche
  def all_served_zones_for_search
    zones = []
    SERVED_ZONES.each do |group_key, group_data|
      group_data[:items].each do |key, item|
        zones << {
          value: "#{group_key}:#{key}",
          label: item[:label],
          code: item[:code] || item[:codes],
          type: item[:type],
          group: group_data[:label],
          searchable: "#{item[:label]} #{item[:code] || item[:codes]&.join(' ')}"
        }
      end
    end
    zones
  end

  # Helper pour obtenir les zones initiales (Île-de-France + Grandes villes)
  def initial_served_zones
    zones = []
    ["ile_de_france", "grandes_villes"].each do |group_key|
      group_data = SERVED_ZONES[group_key]
      group_data[:items].each do |key, item|
        zones << {
          value: "#{group_key}:#{key}",
          label: item[:label],
          code: item[:code] || item[:codes],
          type: item[:type],
          group: group_data[:label]
        }
      end
    end
    zones
  end
end
