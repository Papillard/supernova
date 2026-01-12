class Teacher::RequestsController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :set_teacher
  before_action :set_request, only: [:show, :accept, :decline, :archive]

  def index
    authorize Request
    @requests = policy_scope(Request).visible_to_teacher.order(last_message_at: :desc)

    # Déterminer la request active
    if params[:id].present?
      @active_request = @requests.find_by(id: params[:id])
    else
      @active_request = @requests.first
    end

    # Marquer la request active comme lue
    @active_request&.mark_as_read_by_teacher!
  end

  def show
    authorize @request
    redirect_to teacher_requests_path(id: params[:id])
  end

  def accept
    authorize @request
    if @request.update(status: :accepted, responded_at: Time.current)
      teacher = @request.teacher
      full_name = "#{teacher.first_name} #{teacher.last_name}"

      phone_text = if teacher.phone.present?
        teacher.phone
      else
        "Préfère échanger sur ProfConnect ou par mail"
      end

      message_body = "#{full_name} a accepté votre demande de connexion !\n\nNous vous partageons ses informations pour continuer à échanger et vous organiser ensemble:\n\n- Email: #{teacher.email_pro}\n- Telephone: #{phone_text}\n\nBon échange !"

      Message.create!(
        request: @request,
        user: current_user,
        body: message_body,
        system: true
      )
      redirect_to teacher_requests_path(id: @request.id), notice: "Demande acceptée."
    else
      redirect_to teacher_requests_path(id: @request.id), alert: "Erreur lors de l'acceptation."
    end
  end

  def decline
    authorize @request
    if @request.update(status: :declined, responded_at: Time.current)
      Message.create!(
        request: @request,
        user: current_user,
        body: "Le professeur a refusé la demande.",
        system: true
      )
      redirect_to teacher_requests_path(id: @request.id), notice: "Demande refusée."
    else
      redirect_to teacher_requests_path(id: @request.id), alert: "Erreur lors du refus."
    end
  end

  def archive
    authorize @request

    if @request.update(archived_by_teacher: true)
      redirect_to teacher_requests_path, notice: "Demande archivée."
    else
      redirect_to teacher_requests_path(id: @request.id), alert: "Erreur lors de l'archivage."
    end
  end

  private

  def set_teacher
    @teacher = current_user&.teacher
    redirect_to root_path, alert: "Vous devez être professeur." unless @teacher
  end

  def set_request
    @request = Request.find(params[:id])
  end
end
