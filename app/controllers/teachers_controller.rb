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

    # Filtre par ville
    if params[:city].present?
      @teachers = @teachers.where("LOWER(city) LIKE ?", "%#{params[:city].downcase}%")
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
  rescue ActiveRecord::RecordNotFound
    redirect_to teachers_path, alert: "Professeur non trouvé ou non disponible."
  end
end
