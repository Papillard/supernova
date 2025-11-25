class TeachersController < ApplicationController
  layout "authenticated" if -> { user_signed_in? }

  def index
    @teachers = Teacher.public_visible

    # Filtre par niveau
    if params[:level].present?
      @teachers = @teachers.where("? = ANY(levels)", params[:level])
    end

    # Filtre par matière
    if params[:subject].present?
      @teachers = @teachers.where("? = ANY(subjects_tags)", params[:subject])
    end

    # Filtre par arrondissement (code postal commence par 75xxx pour Paris)
    if params[:arrondissement].present?
      arrondissement_code = params[:arrondissement].to_s.rjust(2, '0')
      @teachers = @teachers.where("base_zip_code LIKE ?", "75#{arrondissement_code}%")
    end

    @teachers = @teachers.order(:display_name)
  end

  def show
    @teacher = Teacher.public_visible.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teachers_path, alert: "Professeur non trouvé ou non disponible."
  end
end
