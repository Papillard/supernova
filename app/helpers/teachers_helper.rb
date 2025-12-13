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
    ["Parcoursup", "parcoursup"]
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
      "#{teacher.first_name} #{teacher.last_name[0].upcase}"
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

    # Mapping des valeurs courantes
    radius_mapping = {
      "deux_a_5_km" => "2 à 5 km",
      "5_a_10_km" => "5 à 10 km",
      "10_a_20_km" => "10 à 20 km",
      "plus_de_20_km" => "Plus de 20 km"
    }

    # Vérifier si c'est une valeur mappée
    if radius_mapping.key?(radius_text.downcase)
      return radius_mapping[radius_text.downcase]
    end

    # Si le texte contient déjà "km", on le retourne tel quel
    return radius_text if radius_text.downcase.include?("km")

    # Sinon, on essaie d'extraire un nombre et on ajoute "km"
    if radius_text.match?(/\d+/)
      number = radius_text.scan(/\d+/).first
      "#{number} km"
    else
      radius_text.humanize
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

  # Helper pour formater un tag d'examen
  def format_exam_tag(tag)
    exam_option = EXAM_TAGS_OPTIONS.find { |_, value| value == tag }
    if exam_option
      exam_option[0]
    else
      tag.humanize
    end
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

  # Helper pour formater le texte des tarifs (ajoute "/ heure" si absent)
  def format_pricing_text(pricing_text)
    return "" if pricing_text.blank?

    # Si le texte contient déjà "/ heure" ou "par heure" ou "heure", on le retourne tel quel
    return pricing_text if pricing_text.downcase.match?(/(\/\s*heure|par\s+heure|heure)/)

    # Sinon, on ajoute "/ heure" à la fin
    "#{pricing_text} / heure"
  end

  # Helper pour formater la localisation de manière naturelle
  def format_location_text(teacher)
    parts = []

    # Adresse complète
    if teacher.city.present?
      location_str = teacher.city
      if teacher.zip_code.present?
        location_str += " (#{teacher.zip_code})"
      end
      parts << "Habite à #{location_str}"
    elsif teacher.address.present?
      parts << "📍 #{teacher.address}"
      if teacher.zip_code.present?
        parts << "(#{teacher.zip_code})"
      end
    elsif teacher.zip_code.present?
      parts << "📍 #{teacher.zip_code}"
    end

    # Rayon
    if teacher.radius_text.present?
      radius_formatted = format_radius_human(teacher.radius_text)
      if parts.any?
        parts << "peut donner cours dans un rayon de #{radius_formatted}"
      else
        parts << "Rayon d'intervention : #{radius_formatted}"
      end
    end

    parts.join(", ")
  end
end
