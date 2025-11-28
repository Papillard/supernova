module Admin
  class TeachersController < ApplicationController
    layout "authenticated"
    before_action :authenticate_user!
    # TODO: Add admin authorization check when admin system is implemented

    def index
      @teachers = Teacher.all.order(created_at: :desc)
      @teachers = @teachers.where(status: params[:status]) if params[:status].present?
    end

    def show
      @teacher = Teacher.find(params[:id])
    end

    def approve
      @teacher = Teacher.find(params[:id])
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
      @teacher = Teacher.find(params[:id])
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
  end
end
