class StudentsController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :set_parent_profile
  before_action :set_student, only: [:destroy]

  def create
    @student = @parent_profile.students.build(student_params)
    authorize @student

    respond_to do |format|
      if @student.save
        @parent_profile.reload
        format.turbo_stream { render :create }
        format.html do
          flash[:notice] = "Enfant ajouté avec succès."
          redirect_to parent_profile_path
        end
      else
        format.turbo_stream do
          flash.now[:alert] = "Erreur lors de l'ajout de l'enfant : #{@student.errors.full_messages.join(', ')}"
          render :create, status: :unprocessable_entity
        end
        format.html do
          flash[:alert] = "Erreur lors de l'ajout de l'enfant : #{@student.errors.full_messages.join(', ')}"
          redirect_to parent_profile_path
        end
      end
    end
  end

  def destroy
    authorize @student
    @student.destroy
    flash[:notice] = "Enfant supprimé avec succès."
    redirect_to parent_profile_path
  end

  private

  def set_parent_profile
    @parent_profile = current_user.parent_profile
    redirect_to parent_profile_path, alert: "Veuillez d'abord créer votre profil." unless @parent_profile
  end

  def set_student
    @student = @parent_profile.students.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:first_name, :birth_year)
  end
end
