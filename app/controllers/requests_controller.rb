class RequestsController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :ensure_parent_role

  def index
    @requests = current_user.requests_as_parent.order(last_message_at: :desc)

    # Déterminer la request active
    if params[:id].present?
      @active_request = @requests.find_by(id: params[:id])
    else
      @active_request = @requests.first
    end
  end

  def show
    redirect_to requests_path(id: params[:id])
  end

  def create
    @teacher = Teacher.find(params[:teacher_id])

    # Vérifier que le teacher est approved et a rgpd_consent
    unless @teacher.status == "approved" && @teacher.rgpd_consent
      redirect_to teacher_path(@teacher), alert: "Ce professeur n'est pas disponible pour les demandes."
      return
    end

    @request = Request.new(request_params)
    @request.parent = current_user
    @request.teacher = @teacher
    @request.status = :pending
    @request.requested_at = Time.current
    @request.last_message_at = Time.current

    if @request.save
      # Récupérer les prénoms
      teacher_first_name = @teacher.first_name.presence || "Professeur"
      parent_first_name = current_user.first_name.presence || "Parent"

      # Formater la matière et le niveau
      subject_label = TeachersHelper::SUBJECTS_OPTIONS.find { |_, value| value == @request.subject }&.first || @request.subject.humanize
      level_label = RequestsHelper::LEVELS_OPTIONS.find { |_, value| value == @request.level }&.first || @request.level.humanize

      # Créer le premier message du parent
      parent_message_body = <<~MESSAGE
        Bonjour #{teacher_first_name},

        Je recherche des cours particulier en #{subject_label} niveau #{level_label} pour mon enfant.

        Quelques informations utiles :

        #{@request.request_text}

        Merci d'avance pour votre réponse,

        #{parent_first_name}
      MESSAGE

      Message.create!(
        request: @request,
        user: current_user,
        body: parent_message_body.strip,
        system: false
      )

      # Créer le message système après
      # Utiliser le display_name généré automatiquement (Prénom + Initiale)
      display_name = "#{@teacher.first_name} #{@teacher.last_name[0].upcase}" if @teacher.first_name.present? && @teacher.last_name.present?
      display_name ||= @teacher.first_name if @teacher.first_name.present?
      display_name ||= "Professeur"

      Message.create!(
        request: @request,
        user: current_user,
        body: "Votre demande a été envoyée. #{display_name} vous répondra ici.",
        system: true
      )

      redirect_to requests_path(id: @request.id), notice: "Votre demande a été envoyée avec succès."
    else
      redirect_to teacher_path(@teacher), alert: "Erreur lors de la création de la demande."
    end
  end

  private

  def request_params
    params.require(:request).permit(:subject, :level, :request_text)
  end

  def ensure_parent_role
    unless current_user.parent?
      redirect_to root_path, alert: "Accès réservé aux parents."
    end
  end
end
