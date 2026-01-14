class TeachersController < ApplicationController
  layout "authenticated" if -> { user_signed_in? }

  def index
    @teachers = policy_scope(Teacher)

    # Filtre par niveau
    if params[:level].present?
      @teachers = @teachers.where("? = ANY(levels)", params[:level])
    end

    # Filtre par matière
    if params[:subject].present?
      @teachers = @teachers.where("? = ANY(subjects_tags)", params[:subject])
    end

    # Filtre par zone (ville ou département) - single select
    if params[:zones].present?
      zone_value = params[:zones].to_s
      # Chercher les teachers qui ont cette zone dans served_zones
      @teachers = @teachers.where("? = ANY(served_zones)", zone_value)
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
