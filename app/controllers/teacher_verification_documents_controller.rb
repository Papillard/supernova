class TeacherVerificationDocumentsController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :set_teacher

  def create
    authorize @teacher, policy_class: TeacherVerificationDocumentPolicy
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
          # Upload to storage FIRST, then attach only once the file is safely
          # stored. This prevents a failed upload from leaving a phantom
          # attachment that shows up in the list but points to a missing file.
          blob = ActiveStorage::Blob.create_and_upload!(
            io: document.open,
            filename: document.original_filename,
            content_type: document.content_type
          )
          @teacher.verification_documents.attach(blob)
          attached_count += 1
        rescue => e
          Rails.logger.error "Error attaching document: #{e.class} - #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          errors << "#{filename}: Erreur lors de l'upload (#{e.message})"
        end
      end

      @teacher.reload

      if errors.any?
        flash.now[:alert] = errors.join(". ")
      elsif attached_count > 0
        flash.now[:notice] = "#{attached_count} document(s) ajouté(s) avec succès."
      end

      respond_to do |format|
        format.turbo_stream { render :create }
        format.html { redirect_to teacher_profile_path }
      end
    else
      flash.now[:alert] = "Veuillez sélectionner au moins un fichier."
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to teacher_profile_path, alert: "Veuillez sélectionner au moins un fichier." }
      end
    end
  end

  def destroy
    @document = @teacher.verification_documents.find_by_blob_id(params[:id])
    authorize @document, policy_class: TeacherVerificationDocumentPolicy if @document
    if @document
      purge_document(@document)
      @teacher.reload

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Document supprimé avec succès."
          render :destroy
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

  def set_teacher
    @teacher = current_user&.teacher
  end

  # Purge an attachment, tolerating an unreachable storage backend.
  # Old documents may still live on a decommissioned bucket; if the storage
  # delete fails we still remove the DB records so the document disappears
  # from the UI instead of raising a 500.
  def purge_document(attachment)
    attachment.purge
  rescue => e
    Rails.logger.warn "Purge failed for blob #{attachment.blob_id}, removing DB records only: #{e.class} - #{e.message}"
    blob = attachment.blob
    attachment.destroy
    blob&.destroy
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
