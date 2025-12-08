class TeacherVerificationDocumentsController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_teacher

  def create
    if params[:verification_documents].present?
      attached_count = 0
      errors = []

      params[:verification_documents].each do |document|
        filename = document.respond_to?(:original_filename) ? document.original_filename : "fichier"

        # Validation du type MIME
        unless valid_document_type?(document)
          errors << "#{filename}: Format non supporté. Formats acceptés : Images (JPEG, PNG) et PDF."
          next
        end

        begin
          @teacher.verification_documents.attach(document)
          attached_count += 1
        rescue => e
          Rails.logger.error "Error attaching document: #{e.class} - #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          errors << "#{filename}: Erreur lors de l'upload (#{e.message})"
        end
      end

      @teacher.reload

      respond_to do |format|
        if attached_count > 0
          if errors.any?
            flash.now[:alert] = "#{attached_count} document(s) ajouté(s). Erreurs : #{errors.join(', ')}"
          else
            flash.now[:notice] = "#{attached_count} document(s) ajouté(s) avec succès."
          end
          format.turbo_stream
          format.html { redirect_to teacher_profile_path, notice: "#{attached_count} document(s) ajouté(s) avec succès." }
        else
          flash.now[:alert] = errors.any? ? errors.join(', ') : "Aucun document n'a pu être ajouté."
          format.turbo_stream { render :create, status: :unprocessable_entity }
          format.html { redirect_to teacher_profile_path, alert: errors.any? ? errors.join(', ') : "Aucun document n'a pu être ajouté." }
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Aucun document sélectionné."
          render :create, status: :unprocessable_entity
        end
        format.html do
          flash[:alert] = "Aucun document sélectionné."
          redirect_to teacher_profile_path
        end
      end
    end
  end

  def destroy
    @document = @teacher.verification_documents.find_by_blob_id(params[:id])
    if @document
      @document.purge
      @teacher.reload

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Document supprimé avec succès."
        end
        format.html { redirect_to teacher_profile_path, notice: "Document supprimé avec succès." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Document non trouvé."
          render :destroy, status: :not_found
        end
        format.html do
          flash[:alert] = "Document non trouvé."
          redirect_to teacher_profile_path
        end
      end
    end
  end

  private

  def ensure_teacher!
    redirect_to root_path unless current_user&.teacher?
  end

  def set_teacher
    @teacher = current_user.teacher
  end

  def valid_document_type?(document)
    return false unless document.respond_to?(:content_type)

    allowed_types = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'application/pdf'
    ]

    allowed_types.include?(document.content_type)
  end
end
