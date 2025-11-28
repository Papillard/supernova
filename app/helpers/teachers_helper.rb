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
    elsif teacher.display_name.present?
      teacher.display_name
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
end
