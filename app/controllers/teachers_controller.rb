class TeachersController < ApplicationController
  layout "authenticated" if -> { user_signed_in? }

  def index
    @teachers = Teacher.public_visible

    # Filtres simples
    @teachers = @teachers.where("base_city ILIKE ?", "%#{params[:city]}%") if params[:city].present?
    @teachers = @teachers.where("? = ANY(levels)", params[:level]) if params[:level].present?
    @teachers = @teachers.where("? = ANY(subjects_tags)", params[:subject]) if params[:subject].present?

    @teachers = @teachers.order(:display_name)
  end

  def show
    @teacher = Teacher.public_visible.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teachers_path, alert: "Professeur non trouvé ou non disponible."
  end
end
