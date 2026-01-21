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
    ["Lecture / Écriture", "lecture_ecriture"],
    ["Mathématiques", "mathematiques"],
    ["Français", "francais"],
    ["Anglais", "anglais"],
    ["Physique-Chimie", "physique-chimie"],
    ["SVT", "svt"],
    ["Histoire-Géographie", "histoire-geographie"],
    ["SES", "ses"],
    ["Espagnol", "espagnol"],
    ["Allemand", "allemand"],
    ["Philosophie", "philosophie"],
    ["NSI", "nsi"],
    ["SNT", "snt"],
    ["SI (Sciences de l'Ingénieur)", "si_sciences_ingenieur"],
    ["HGGSP", "hggsp"],
    ["HLP", "hlp"],
    ["LLCE Anglais", "llce_anglais"],
    ["LLCE Espagnol", "llce_espagnol"],
    ["Économie", "economie"],
    ["Sciences politiques", "sciences_politiques"],
    ["Droit", "droit"],
    ["Informatique", "informatique"],
    ["Technologie", "technologie"],
    ["Littérature", "litterature"],
    ["Géopolitique", "geopolitique"],
    ["Comptabilité & Gestion", "comptabilite_gestion"],
    ["Finance", "finance"],
    ["Marketing", "marketing"],
    ["Psychologie", "psychologie"],
    ["Orientation", "orientation"],
    ["EPS (Éducation Physique et Sportive)", "eps"],
    ["Arts plastiques", "arts_plastiques"],
    ["Éducation musicale", "education_musicale"],
    ["Latin", "latin"],
    ["Grec", "grec"],
    ["LCA (Langues et Cultures de l'Antiquité)", "lca"],
    ["Italien", "italien"],
    ["LSF (Langue des Signes Française)", "lsf"]
  ].freeze

  # Groupements de matières pour l'affichage dans la modale
  SUBJECTS_GROUPED = {
    "Fondamentaux" => [
      ["Aide aux devoirs", "aide_aux_devoirs"],
      ["Lecture / Écriture", "lecture_ecriture"],
      ["Mathématiques", "mathematiques"],
      ["Français", "francais"],
      ["Anglais", "anglais"]
    ],
    "Sciences" => [
      ["Physique-Chimie", "physique-chimie"],
      ["SVT", "svt"],
      ["NSI", "nsi"],
      ["SNT", "snt"],
      ["SI (Sciences de l'Ingénieur)", "si_sciences_ingenieur"]
    ],
    "Sciences humaines & lettres" => [
      ["Histoire-Géographie", "histoire-geographie"],
      ["SES", "ses"],
      ["Philosophie", "philosophie"],
      ["Littérature", "litterature"],
      ["HGGSP", "hggsp"],
      ["HLP", "hlp"],
      ["Géopolitique", "geopolitique"]
    ],
    "Langues" => [
      ["Espagnol", "espagnol"],
      ["Allemand", "allemand"],
      ["Italien", "italien"],
      ["LLCE Anglais", "llce_anglais"],
      ["LLCE Espagnol", "llce_espagnol"],
      ["Latin", "latin"],
      ["Grec", "grec"],
      ["LCA (Langues et Cultures de l'Antiquité)", "lca"],
      ["LSF (Langue des Signes Française)", "lsf"]
    ],
    "Économie / Sup / Pro" => [
      ["Économie", "economie"],
      ["Sciences politiques", "sciences_politiques"],
      ["Droit", "droit"],
      ["Comptabilité & Gestion", "comptabilite_gestion"],
      ["Finance", "finance"],
      ["Marketing", "marketing"],
      ["Informatique", "informatique"]
    ],
    "Autres" => [
      ["Technologie", "technologie"],
      ["Orientation", "orientation"],
      ["Psychologie", "psychologie"],
      ["EPS (Éducation Physique et Sportive)", "eps"],
      ["Arts plastiques", "arts_plastiques"],
      ["Éducation musicale", "education_musicale"]
    ]
  }.freeze

  # Tags examens disponibles (par ordre d'importance)
  EXAM_TAGS_OPTIONS = [
    ["Brevet", "brevet"],
    ["Bac de français", "bac_francais"],
    ["Bac général", "bac_general"],
    ["Bac technologique", "bac_technologique"],
    ["Bac professionnel", "bac_professionnel"],
    ["Grand oral", "grand_oral"],
    ["Parcoursup", "parcoursup"],
    ["Partiels universitaires", "partiels_universitaires"],
    ["Concours IEP / Sciences Po", "concours_iep_sciences_po"],
    ["Concours écoles de commerce", "concours_ecoles_commerce"],
    ["Concours écoles d'ingénieurs", "concours_ecoles_ingenieurs"],
    ["Concours paramédicaux", "concours_paramedicaux"],
    ["Cambridge", "cambridge"],
    ["IELTS", "ielts"],
    ["TOEIC", "toeic"]
  ].freeze

  # Options de rayon de déplacement disponibles
  RADIUS_OPTIONS = [
    ["Moins de 1 km", "moins_de_1_km"],
    ["2 à 5 km", "deux_a_5_km"],
    ["5 à 10 km", "5_a_10_km"],
    ["10 à 20 km", "10_a_20_km"],
    ["Plus de 20 km", "plus_de_20_km"]
  ].freeze

  # Public cible prioritaire (positionnement, card) - Max 2
  TARGET_AUDIENCE_TAGS_OPTIONS = [
    ["Élèves en difficulté", "eleves_en_difficulte"],
    ["Élèves autonomes", "eleves_autonomes_bons_eleves"],
    ["Élèves visant l'excellence", "eleves_visant_excellence"],
    ["Élèves à besoins particuliers", "eleves_besoins_particuliers"]
  ].freeze

  # Accompagnements spécifiques (détail, page prof)
  SPECIFIC_SUPPORT_OPTIONS = [
    ["Préparation aux examens", "preparation_examens"],
    ["Préparation aux concours", "preparation_concours"],
    ["Méthodologie & organisation", "methodologie_organisation"],
    ["Confiance en soi", "confiance_en_soi"],
    ["Orientation / Parcoursup", "orientation_parcoursup"],
    ["FLE (Français Langue Étrangère)", "fle"],
    ["HPI", "hpi"],
    ["TDAH", "tdah"],
    ["Troubles DYS", "troubles_dys"],
    ["Élèves en situation de handicap", "eleves_situation_handicap"]
  ].freeze

  # Tags pédagogie disponibles (par ordre d'importance) - DEPRECATED: utiliser TARGET_AUDIENCE_TAGS_OPTIONS et SPECIFIC_SUPPORT_OPTIONS
  PEDAGOGY_TAGS_OPTIONS = (TARGET_AUDIENCE_TAGS_OPTIONS + SPECIFIC_SUPPORT_OPTIONS).freeze

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
      "at_student_home" => "Chez l'élève",
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
    "concours_iep_sciences_po" => "Sciences Po",
    "concours_ecoles_commerce" => "Écoles commerce",
    "concours_ecoles_ingenieurs" => "Écoles ingénieurs"
  }.freeze

  def format_exam_tag_short(tag)
    EXAM_TAGS_SHORT[tag] || format_exam_tag(tag)
  end

  # Helper pour formater un tag de public cible prioritaire
  def format_target_audience_tag(tag)
    option = TARGET_AUDIENCE_TAGS_OPTIONS.find { |_, value| value == tag }
    option ? option[0] : tag.humanize
  end

  # Helper pour formater un tag d'accompagnement spécifique
  def format_specific_support_tag(tag)
    option = SPECIFIC_SUPPORT_OPTIONS.find { |_, value| value == tag }
    option ? option[0] : tag.humanize
  end

  # Helper pour formater un tag pédagogique (compatibilité avec l'ancien code)
  def format_pedagogy_tag(tag)
    # Essayer d'abord dans target_audience
    option = TARGET_AUDIENCE_TAGS_OPTIONS.find { |_, value| value == tag }
    return option[0] if option
    
    # Puis dans specific_support
    option = SPECIFIC_SUPPORT_OPTIONS.find { |_, value| value == tag }
    return option[0] if option
    
    tag.humanize
  end

  # Version courte pour les cards
  PEDAGOGY_TAGS_SHORT = {
    "methodologie_organisation" => "Méthodologie & organisation",
    "preparation_examens" => "Prépa examens",
    "preparation_concours" => "Prépa concours",
    "besoins_particuliers" => "Besoins particuliers",
    "eleves_situation_handicap" => "Situation handicap"
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

  # Options pour le select career_status (utilisé dans les formulaires)
  # On envoie les clés (certifie, agrege) mais on affiche avec accents
  def career_status_options
    Teacher::CAREER_STATUS_VALUES.map do |key, value|
      display_value = Teacher::CAREER_STATUS_DISPLAY[key]
      [format_career_status(display_value), value]
    end
  end

  # Normalise la valeur de career_status pour la dropdown
  # Convertit les anciennes valeurs avec accent vers les clés sans accent
  def normalize_career_status_for_select(career_status_value)
    return nil if career_status_value.blank?
    
    value = career_status_value.to_s.strip
    valid_values = Teacher::CAREER_STATUS_VALUES.values
    valid_keys = Teacher::CAREER_STATUS_VALUES.keys.map(&:to_s)
    
    # Si c'est déjà une clé valide (stockée en DB), la retourner
    return value if valid_values.include?(value) || valid_keys.include?(value.downcase)
    
    # Mapping pour rétrocompatibilité (anciennes valeurs avec accents -> clés)
    retro_mapping = {
      "certifié" => "certifie",
      "certifie" => "certifie",
      "agrégé" => "agrege",
      "agrege" => "agrege",
      "prof des écoles" => "prof_des_ecoles",
      "prof_des_ecoles" => "prof_des_ecoles",
      "autre" => "autre"
    }
    
    retro_mapping[value.downcase] || value
  end

  # Helper pour formater le statut de carrière avec les accents corrects
  # On reçoit une clé (certifie, agrege) et on retourne l'affichage avec accent
  def format_career_status(career_status)
    return "" if career_status.blank?

    value = career_status.to_s
    key = value.to_sym

    # Si c'est une clé valide, utiliser le mapping d'affichage
    if Teacher::CAREER_STATUS_VALUES.key?(key)
      display_value = Teacher::CAREER_STATUS_DISPLAY[key]
      case display_value
      when "certifié" then "Certifié"
      when "agrégé" then "Agrégé"
      when "prof des écoles" then "Prof des écoles"
      when "autre" then "Autre"
      else display_value.capitalize
      end
    else
      # Rétrocompatibilité : convertir les anciennes valeurs avec accent vers les clés
      retro_key = {
        "certifié" => :certifie,
        "certifie" => :certifie,
        "agrégé" => :agrege,
        "agrege" => :agrege,
        "prof des écoles" => :prof_des_ecoles,
        "prof_des_ecoles" => :prof_des_ecoles,
        "autre" => :autre
      }[value.downcase]

      if retro_key && Teacher::CAREER_STATUS_DISPLAY[retro_key]
        display_value = Teacher::CAREER_STATUS_DISPLAY[retro_key]
        case display_value
        when "certifié" then "Certifié"
        when "agrégé" then "Agrégé"
        when "prof des écoles" then "Prof des écoles"
        when "autre" then "Autre"
        else display_value.capitalize
        end
      else
        value.capitalize
      end
    end
  end

  # Helper pour formater le statut de carrière avec genre (pour les cartes)
  # Retourne "" pour "autre", formate les autres selon le genre
  def format_career_status_for_card(teacher)
    return "" if teacher.career_status.blank?
    
    career_status_key = teacher.career_status.to_s
    
    # Ne rien afficher pour "autre"
    return "" if career_status_key == "autre"
    
    # Adapter le prefix selon le genre
    prefix = if teacher.gender == "female"
      "Professeure"
    elsif teacher.gender == "male"
      "Professeur"
    else
      "Professeur(e)"
    end
    
    # Récupérer la valeur d'affichage depuis le mapping
    key = career_status_key.to_sym
    display_value = Teacher::CAREER_STATUS_DISPLAY[key] || career_status_key
    
    # Formater selon le career_status avec accord au féminin
    case display_value
    when "certifié"
      if teacher.gender == "female"
        "#{prefix} certifiée"
      elsif teacher.gender == "male"
        "#{prefix} certifié"
      else
        "#{prefix} certifié(e)"
      end
    when "agrégé"
      if teacher.gender == "female"
        "#{prefix} agrégée"
      elsif teacher.gender == "male"
        "#{prefix} agrégé"
      else
        "#{prefix} agrégé(e)"
      end
    when "prof des écoles"
      "#{prefix} des écoles"
    else
      # Fallback pour les valeurs non reconnues
      "#{prefix} #{format_career_status(career_status_key).downcase}"
    end
  end

  # Helper pour formater le statut de carrière avec genre et "Éducation nationale"
  def format_career_status_with_gender(teacher)
    return "" if teacher.career_status.blank?

    career_status_formatted = format_career_status(teacher.career_status)
    return "" if career_status_formatted.blank?

    # Adapter selon le genre
    prefix = if teacher.gender == "female"
      "Professeure"
    elsif teacher.gender == "male"
      "Professeur"
    else
      "Professeur(e)"
    end

    "#{prefix} #{career_status_formatted.downcase} Éducation nationale"
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

  # Helper pour formater les zones desservies en labels lisibles
  def format_served_zones_labels(teacher)
    return [] unless teacher.served_zones.present? && teacher.served_zones.any?

    teacher.served_zones.map do |zone_value|
      # zone_value peut être "ile_de_france:paris" ou juste "paris"
      label = nil
      
      if zone_value.to_s.include?(":")
        group_key, key = zone_value.to_s.split(":", 2)
        group_data = SERVED_ZONES[group_key]
        if group_data && group_data[:items]
          # Les clés dans SERVED_ZONES sont des strings
          item = group_data[:items][key] || group_data[:items][key.to_sym]
          label = item[:label] if item
        end
      else
        # Chercher dans toutes les zones
        found_zone = all_served_zones_for_search.find { |z| z[:value].end_with?(":#{zone_value}") || z[:value] == zone_value.to_s }
        label = found_zone[:label] if found_zone
      end
      
      # Si on a trouvé un label, enlever les codes entre parenthèses et retourner
      if label
        label.gsub(/\s*\([^)]*\)/, '').strip
      else
        # Fallback : utiliser la valeur brute mais la formater un peu
        zone_value.to_s.split(":").last.humanize
      end
    end.compact
  end

  # Helper pour construire le sous-titre auto (primary_subject + exam_tags ou target_audience_tags)
  def build_teacher_subtitle(teacher)
    parts = []
    if teacher.primary_subject.present?
      parts << format_subject_tag(teacher.primary_subject)
    end
    if teacher.exam_tags.present?
      parts.concat(teacher.exam_tags.map { |tag| format_exam_tag(tag) })
    elsif teacher.target_audience_tags.present?
      parts.concat(teacher.target_audience_tags.map { |tag| format_target_audience_tag(tag) })
    end
    parts.join(" · ")
  end

  # Helper pour construire "Pourquoi choisir ce professeur" (auto)
  def build_why_choose_teacher(teacher)
    reasons = []
    
    # Ligne 1 = career_status formaté
    if teacher.career_status.present?
      reasons << format_career_status_with_gender(teacher)
    end
    
    # Ligne 2 = exam_tags (si présents)
    if teacher.exam_tags.present?
      exam_text = teacher.exam_tags.map { |tag| format_exam_tag(tag) }.join(" et ")
      reasons << "Préparation au #{exam_text}"
    end
    
    # Ligne 3 = phrase générique fixe
    reasons << "Accompagnement structuré et sérieux"
    
    reasons
  end

  # Helper pour split about_me en bullets (4-5 max)
  # Combine intelligemment les phrases normales ET les list items
  def split_about_me_to_bullets(about_me)
    return [] if about_me.blank?
    
    # Normaliser les retours à la ligne
    text = about_me.gsub(/\r\n/, "\n").gsub(/\r/, "\n").strip
    
    # Pattern pour détecter les bullet points explicites
    bullet_pattern = /^[\s]*[—\-•*▪▫◦‣⁃]\s+(.+)$/
    
    # Séparer le texte en lignes
    lines = text.split(/\n/)
    
    result = []
    current_paragraph = []
    
    lines.each do |line|
      line = line.strip
      next if line.blank?
      
      # Si c'est un bullet point explicite
      if line.match?(bullet_pattern)
        # Si on a accumulé un paragraphe avant, le traiter comme phrase(s)
        if current_paragraph.any?
          paragraph_text = current_paragraph.join(" ").strip
          # Extraire les phrases du paragraphe
          sentences = extract_sentences(paragraph_text)
          result.concat(sentences)
          current_paragraph = []
        end
        
        # Extraire le contenu du bullet point
        match = line.match(bullet_pattern)
        if match
          bullet_content = match[1].strip
          cleaned = clean_bullet(bullet_content)
          result << cleaned if cleaned.present?
        end
      else
        # C'est une ligne normale, l'ajouter au paragraphe en cours
        current_paragraph << line
      end
    end
    
    # Traiter le dernier paragraphe s'il reste
    if current_paragraph.any?
      paragraph_text = current_paragraph.join(" ").strip
      sentences = extract_sentences(paragraph_text)
      result.concat(sentences)
    end
    
    # Si on n'a rien trouvé avec cette méthode, utiliser les méthodes de fallback
    if result.empty?
      result = fallback_extraction(text)
    end
    
    # Limiter à 5 items et nettoyer
    result.first(5).map { |item| clean_bullet(item) }.compact.reject(&:blank?)
  end
  
  private
  
  # Extraire les phrases d'un texte (séparées par . ! ?)
  def extract_sentences(text)
    return [] if text.blank?
    
    # Pattern pour détecter les fins de phrases suivies d'une majuscule
    sentences = text.split(/(?<=[.!?])\s+(?=[A-ZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸ])/)
      .map(&:strip)
      .reject(&:blank?)
    
    # Si on n'a qu'une seule phrase, la retourner telle quelle
    if sentences.length == 1
      [sentences.first]
    elsif sentences.length > 1
      sentences
    else
      # Si le split n'a pas fonctionné, essayer par paragraphes
      text.split(/\n\s*\n/).map(&:strip).reject(&:blank?)
    end
  end
  
  # Méthode de fallback si aucune structure claire n'est détectée
  def fallback_extraction(text)
    # 1. Essayer par paragraphes (lignes vides)
    paragraphs = text.split(/\n\s*\n/).map(&:strip).reject(&:blank?)
    return paragraphs.first(5) if paragraphs.length > 1
    
    # 2. Essayer par phrases
    sentences = text.split(/(?<=[.!?])\s+(?=[A-ZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸ])/)
      .map(&:strip)
      .reject(&:blank?)
    return sentences.first(5) if sentences.length > 1
    
    # 3. Split par retours à la ligne simples
    lines = text.split(/\n/).map(&:strip).reject(&:blank?)
    lines.first(5)
  end
  
  # Nettoyer et formater un bullet point
  def clean_bullet(bullet)
    return nil if bullet.blank?
    
    # Enlever les points finaux (mais garder ! et ?)
    bullet = bullet.gsub(/\.$/, "").strip
    
    # Enlever les tirets/bullets en début de ligne s'il en reste
    bullet = bullet.gsub(/^[\s]*[—\-•*▪▫◦‣⁃]\s*/, "").strip
    
    # Capitaliser intelligemment la première lettre
    if bullet.present?
      # Si la première lettre est minuscule, capitaliser
      if bullet[0].match?(/[a-zàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ]/)
        bullet = bullet[0].upcase + bullet[1..-1]
      end
      
      # S'assurer qu'il n'y a pas d'espaces multiples
      bullet = bullet.gsub(/\s+/, " ").strip
    end
    
    bullet.present? ? bullet : nil
  end
end
