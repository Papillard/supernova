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

    # Vérifier que le parent a un profil
    parent_profile = current_user.parent_profile
    unless parent_profile
      redirect_to parent_profile_path, alert: "Veuillez d'abord créer votre profil."
      return
    end

    student = nil
    student_errors = nil

    # Utiliser une transaction pour créer l'étudiant et la demande
    ActiveRecord::Base.transaction do
      student_id_param = request_params[:student_id]

      # Si student_id == "new", créer un nouvel étudiant
      if student_id_param == "new"
        student_attributes = request_params[:student_attributes] || {}
        student = parent_profile.students.build(
          first_name: student_attributes[:first_name],
          birth_year: student_attributes[:birth_year]
        )

        unless student.save
          student_errors = student.errors
          raise ActiveRecord::Rollback
        end
      elsif student_id_param.present?
        # Utiliser l'étudiant existant
        student = parent_profile.students.find_by(id: student_id_param)
        unless student
          redirect_to teacher_path(@teacher), alert: "Enfant introuvable."
          return
        end
      else
        redirect_to teacher_path(@teacher), alert: "Veuillez sélectionner ou créer un enfant."
        return
      end

      # Inférer le niveau depuis l'année de naissance de l'enfant
      inferred_level = student.level
      unless inferred_level
        redirect_to teacher_path(@teacher), alert: "Impossible de déterminer le niveau de l'enfant."
        return
      end

      @request = Request.new(request_params.except(:student_id, :student_attributes))
      @request.parent = current_user
      @request.teacher = @teacher
      @request.student = student
      @request.level = inferred_level
      @request.status = :pending
      @request.requested_at = Time.current
      @request.last_message_at = Time.current

      # Utiliser notes si fourni, sinon request_text pour compatibilité
      @request.request_text = @request.notes.presence || @request.request_text || ""

      unless @request.save
        raise ActiveRecord::Rollback
      end

      # Récupérer les prénoms
      teacher_first_name = @teacher.first_name.presence || "Professeur"
      parent_first_name = current_user.parent_profile&.first_name.presence || current_user.first_name.presence || "Parent"

      # Formater la matière et le niveau
      subject_label = TeachersHelper::SUBJECTS_OPTIONS.find { |_, value| value == @request.subject }&.first || @request.subject.humanize
      level_label = RequestsHelper::LEVELS_OPTIONS.find { |_, value| value == @request.level }&.first || @request.level.humanize

      # Créer le premier message du parent
      student_name = student.first_name
      notes_text = @request.notes.present? ? "\n\n#{@request.notes}" : ""

      parent_message_body = <<~MESSAGE
        Bonjour #{teacher_first_name},

        Je recherche des cours particulier en #{subject_label} niveau #{level_label} pour #{student_name}.#{notes_text}

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
    end

    # Après la transaction
    if @request&.persisted?
      redirect_to requests_path(id: @request.id), notice: "Votre demande a été envoyée avec succès."
    else
      # Préparer les erreurs pour l'affichage
      @student_errors = student_errors
      @request_errors = @request&.errors

      # Stocker les erreurs dans flash pour les afficher dans le modal
      if student_errors
        flash.now[:alert] = "Erreur lors de la création de l'enfant : #{student_errors.full_messages.join(', ')}"
      elsif @request&.errors&.any?
        # Si on a une erreur sur :base, l'utiliser directement (message personnalisé sans préfixe)
        if @request.errors[:base].any?
          flash.now[:alert] = @request.errors[:base].first
        else
          flash.now[:alert] = @request.errors.full_messages.join(', ')
        end
      else
        flash.now[:alert] = "Erreur lors de la création de la demande."
      end

      # Re-rendre la page du teacher avec le modal ouvert
      # On doit charger le teacher et rendre la vue
      @teacher = Teacher.find(params[:teacher_id])

      # Préserver les valeurs du formulaire en cas d'erreur
      @form_student_id = request_params[:student_id]
      @form_student_attributes = request_params[:student_attributes] || {}
      @form_subject = request_params[:subject]
      @form_level = request_params[:level]
      @form_notes = request_params[:notes]

      render 'teachers/show', status: :unprocessable_entity, layout: 'authenticated'
    end
  end

  private

  def request_params
    params.require(:request).permit(:subject, :level, :request_text, :notes, :student_id, student_attributes: [:first_name, :birth_year])
  end

  def ensure_parent_role
    unless current_user.parent?
      redirect_to root_path, alert: "Accès réservé aux parents."
    end
  end
end
