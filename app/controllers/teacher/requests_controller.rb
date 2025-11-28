class Teacher::RequestsController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :ensure_teacher_role
  before_action :set_teacher
  before_action :set_request, only: [:show, :accept, :decline]
  before_action :authorize_request_access, only: [:show, :accept, :decline]

  def index
    @requests = @teacher.requests.recent
  end

  def show
    @messages = @request.messages.order(created_at: :asc)
  end

  def accept
    if @request.update(status: :accepted, responded_at: Time.current)
      Message.create!(
        request: @request,
        user: current_user,
        body: "Le professeur a accepté la demande.",
        system: true
      )
      redirect_to teacher_request_path(@request), notice: "Demande acceptée."
    else
      redirect_to teacher_request_path(@request), alert: "Erreur lors de l'acceptation."
    end
  end

  def decline
    if @request.update(status: :declined, responded_at: Time.current)
      Message.create!(
        request: @request,
        user: current_user,
        body: "Le professeur a refusé la demande.",
        system: true
      )
      redirect_to teacher_request_path(@request), notice: "Demande refusée."
    else
      redirect_to teacher_request_path(@request), alert: "Erreur lors du refus."
    end
  end

  private

  def set_teacher
    @teacher = current_user.teacher
    redirect_to root_path, alert: "Vous devez être professeur." unless @teacher
  end

  def set_request
    @request = Request.find(params[:id])
  end

  def authorize_request_access
    unless @request.teacher_id == @teacher.id
      redirect_to teacher_requests_path, alert: "Vous n'avez pas accès à cette demande."
    end
  end

  def ensure_teacher_role
    unless current_user.teacher?
      redirect_to root_path, alert: "Accès réservé aux professeurs."
    end
  end
end
