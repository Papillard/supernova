module TeachersHelper
  # Niveaux disponibles (par ordre d'importance)
  LEVELS_OPTIONS = [
    ["Primaire", "primaire"],
    ["Collège", "college"],
    ["Lycée", "lycee"],
    ["Prépa et Supérieur", "prepa"],
    ["Autre", "autre"]
  ].freeze

  # Matières disponibles groupées par section
  SUBJECTS_OPTIONS_GROUPED = {
    "Tronc commun collège / lycée" => [
      ["Mathématiques", "mathematiques"],
      ["Français", "francais"],
      ["Anglais", "anglais"],
      ["Espagnol", "espagnol"],
      ["Allemand", "allemand"],
      ["Italien", "italien"],
      ["Physique-Chimie", "physique-chimie"],
      ["SVT", "svt"],
      ["Histoire-Géographie", "histoire-geographie"],
      ["SES", "ses"],
      ["EMC", "emc"],
      ["Technologie", "technologie"],
      ["SNT", "snt"],
      ["NSI", "nsi"]
    ],
    "Primaire" => [
      ["Toutes matières primaire", "toutes_matieres_primaire"],
      ["Lecture / Écriture", "lecture_ecriture"],
      ["Maths primaire", "maths_primaire"]
    ],
    "Prépa et Supérieur" => [
      ["Maths expertes", "maths_expertes"],
      ["Maths complémentaires", "maths_complementaires"],
      ["Philosophie", "philosophie"],
      ["Littérature", "litterature"],
      ["Géopolitique", "geopolitique"],
      ["HGGSP", "hggsp"],
      ["HLP", "hlp"],
      ["Économie", "economie"],
      ["Sciences politiques", "sciences_politiques"],
      ["Droit", "droit"],
      ["Comptabilité", "comptabilite"],
      ["Gestion", "gestion"],
      ["Finance", "finance"],
      ["Marketing", "marketing"],
      ["Psychologie", "psychologie"],
      ["Informatique", "informatique"]
    ],
    "Langues et FLE" => [
      ["FLE", "fle"],
      ["Anglais professionnel", "anglais_professionnel"],
      ["Anglais conversation", "anglais_conversation"]
    ]
  }.freeze

  # Liste plate pour compatibilité (toutes les matières dans l'ordre)
  SUBJECTS_OPTIONS = SUBJECTS_OPTIONS_GROUPED.values.flatten(1).freeze

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
end
