class TeachersController < ApplicationController
  layout "authenticated" if -> { user_signed_in? }

  def index
    @teachers = policy_scope(Teacher).approved

    # Filtre par niveau
    if params[:level].present?
      @teachers = @teachers.where("? = ANY(levels)", params[:level])
    end

    # Filtre par matière
    # Chercher dans primary_subject OU dans subjects_tags (merge des deux)
    if params[:subject].present?
      subject_value = params[:subject].to_s.strip
      # Normaliser les accents pour la comparaison
      # La valeur standard est "mathematiques" (sans accent) mais on gère aussi "mathématiques" (avec accent)
      normalized_value = subject_value.unicode_normalize(:nfd).gsub(/[\u0300-\u036f]/, '').downcase
      
      # Chercher dans primary_subject OU dans subjects_tags
      # Utiliser translate pour supprimer les accents dans PostgreSQL
      @teachers = @teachers.where(
        "LOWER(translate(primary_subject, 'àáâãäåèéêëìíîïòóôõöùúûüýÿ', 'aaaaaaeeeeiiiioooouuuuyy')) = ? 
        OR LOWER(primary_subject) = LOWER(?)
        OR EXISTS (
          SELECT 1 FROM unnest(subjects_tags) AS tag 
          WHERE LOWER(translate(tag, 'àáâãäåèéêëìíîïòóôõöùúûüýÿ', 'aaaaaaeeeeiiiioooouuuuyy')) = ?
          OR LOWER(tag) = LOWER(?)
        )",
        normalized_value, subject_value, normalized_value, subject_value
      )
    end

    # Filtre par zone (ville ou département) - single select
    if params[:zones].present?
      zone_value = params[:zones].to_s.strip
      # Chercher les teachers qui ont cette zone dans served_zones
      # La zone peut être au format "group_key:key" (ex: "ile_de_france:paris")
      # Utiliser ? = ANY(served_zones) pour vérifier si l'array contient la valeur (même syntaxe que pour levels et subjects_tags)
      Rails.logger.debug "Filtering teachers by zone: #{zone_value.inspect}"
      @teachers = @teachers.where("? = ANY(served_zones)", zone_value)
      Rails.logger.debug "Found #{@teachers.count} teachers matching zone #{zone_value}"
    end

    # Filtre par format d'enseignement
    if params[:format].present?
      @teachers = @teachers.where("? = ANY(teaching_formats)", params[:format])
    end

    @teachers = @teachers.order(:display_name)
  end

  def show
    @teacher = Teacher.find(params[:id])
    authorize @teacher

    # Vérifier si le parent a déjà une requête active avec ce professeur
    if user_signed_in? && current_user.parent?
      @has_active_request = Request.active
                                    .where(parent_id: current_user.id, teacher_id: @teacher.id)
                                    .exists?
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to teachers_path, alert: "Professeur non trouvé ou non disponible."
  end
end
