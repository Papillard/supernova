module Admin
  class TeachersController < ApplicationController
    layout "authenticated"
    before_action :authenticate_user!
    before_action :set_teacher, only: [:show, :approve, :reject]

    rescue_from Pundit::NotAuthorizedError, with: :redirect_non_admin

    def index
      authorize [:admin, Teacher]
      @teachers = policy_scope([:admin, Teacher])
      @teachers = @teachers.where(status: params[:status]) if params[:status].present?
      @teachers = @teachers.order(created_at: :desc)
    end

    def show
      authorize [:admin, @teacher]
    end

    def approve
      authorize [:admin, @teacher]
      if @teacher.update(status: :approved)
        display_name = "#{@teacher.first_name} #{@teacher.last_name[0].upcase}" if @teacher.first_name.present? && @teacher.last_name.present?
        display_name ||= @teacher.first_name if @teacher.first_name.present?
        display_name ||= "Professeur"
        flash[:notice] = "Le professeur #{display_name} a été approuvé."
      else
        flash[:alert] = "Erreur lors de l'approbation."
      end
      redirect_to admin_teacher_path(@teacher)
    end

    def reject
      authorize [:admin, @teacher]
      if @teacher.update(status: :rejected)
        display_name = "#{@teacher.first_name} #{@teacher.last_name[0].upcase}" if @teacher.first_name.present? && @teacher.last_name.present?
        display_name ||= @teacher.first_name if @teacher.first_name.present?
        display_name ||= "Professeur"
        flash[:notice] = "Le professeur #{display_name} a été refusé."
      else
        flash[:alert] = "Erreur lors du refus."
      end
      redirect_to admin_teacher_path(@teacher)
    end

    private

    def set_teacher
      @teacher = Teacher.find(params[:id])
    end

    def redirect_non_admin
      redirect_to root_path, alert: "Accès réservé aux administrateurs."
    end
  end
end
