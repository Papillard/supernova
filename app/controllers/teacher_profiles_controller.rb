class TeacherProfilesController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :create_teacher_if_missing
  before_action :set_teacher

  def show
    # Display the profile form
  end

  def update
    # Détecter si c'est un upload d'avatar uniquement (formulaire séparé)
    is_avatar_only = params[:avatar_only].present?

    params_hash = teacher_params.to_h

    # Si c'est un upload d'avatar uniquement, ne traiter que les champs avatar et picture_visible
    if is_avatar_only
      params_hash = params_hash.slice(:picture_visible, :profile_image_url, :profile_image_attached)
    else
      # Les multi-selects envoient déjà des arrays, mais peuvent être vides
      # S'assurer que les champs array sont bien des arrays
      %w[subjects_tags levels exam_tags pedagogy_tags].each do |field|
        if params_hash[field].present?
          params_hash[field] = Array(params_hash[field]).reject(&:blank?)
        else
          params_hash[field] = []
        end
      end

      # Handle teaching_formats checkboxes
      if params[:teacher][:teaching_formats].present?
        params_hash[:teaching_formats] = Array(params[:teacher][:teaching_formats]).reject(&:blank?)
      else
        params_hash[:teaching_formats] = []
      end
    end

    # Handle avatar upload
    if params[:teacher].present? && params[:teacher][:avatar].present?
      avatar_file = params[:teacher][:avatar]

      # Validation basique du type MIME
      allowed_types = ['image/jpeg', 'image/jpg', 'image/png']
      unless avatar_file.respond_to?(:content_type) && allowed_types.include?(avatar_file.content_type)
        flash[:alert] = "Format d'image non supporté. Veuillez utiliser JPEG ou PNG."
        render :show, status: :unprocessable_entity
        return
      end

      begin
        # Vérifier que Cloudinary est configuré
        unless ENV["CLOUDINARY_URL"].present?
          flash[:alert] = "Configuration Cloudinary manquante. Veuillez contacter l'administrateur."
          render :show, status: :unprocessable_entity
          return
        end

        # S'assurer que la configuration Cloudinary est chargée
        if Cloudinary.config.cloud_name.blank?
          Cloudinary.config_from_url(ENV["CLOUDINARY_URL"])
        end

        # Vérifier que la config est valide
        cloud_name = Cloudinary.config.cloud_name
        if cloud_name.blank? || cloud_name == "cloud_name"
          flash[:alert] = "Configuration Cloudinary invalide. Votre CLOUDINARY_URL contient 'cloud_name' au lieu du vrai nom de votre cloud. Vérifiez votre variable d'environnement CLOUDINARY_URL dans le dashboard Cloudinary."
          render :show, status: :unprocessable_entity
          return
        end

        # Upload vers Cloudinary
        # Avec ActionDispatch::Http::UploadedFile, utiliser tempfile directement
        file_to_upload = if avatar_file.respond_to?(:tempfile)
          # ActionDispatch::Http::UploadedFile
          avatar_file.tempfile
        elsif avatar_file.respond_to?(:path) && File.exist?(avatar_file.path)
          # File object
          avatar_file
        else
          # Fallback : utiliser le fichier uploadé directement
          avatar_file
        end

        upload_result = Cloudinary::Uploader.upload(file_to_upload, {
          folder: "profconnect/teachers",
          resource_type: "image"
        })

        if upload_result && upload_result["secure_url"].present?
          params_hash[:profile_image_url] = upload_result["secure_url"]
          params_hash[:profile_image_attached] = true
        else
          flash[:alert] = "Erreur lors de l'upload : réponse invalide de Cloudinary."
          render :show, status: :unprocessable_entity
          return
        end
      rescue => e
        Rails.logger.error "Cloudinary upload error: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        flash[:alert] = "Erreur lors de l'upload de la photo : #{e.message}"
        render :show, status: :unprocessable_entity
        return
      end
    end

    # Retirer 'avatar' de params_hash car ce n'est pas un attribut du modèle
    # C'est juste un fichier temporaire pour l'upload
    params_hash.delete(:avatar)

    # Détecter si c'est un upload d'avatar pour répondre avec turbo_stream
    is_avatar_upload = is_avatar_only || (params[:teacher].present? && params[:teacher][:avatar].present?)

    respond_to do |format|
      if @teacher.update(params_hash)
        if is_avatar_upload
          # Recharger le teacher pour avoir les dernières données
          @teacher.reload
          format.turbo_stream { render :update }
          format.html { redirect_to teacher_profile_path, notice: "Photo de profil mise à jour avec succès." }
        else
          format.html do
            flash[:notice] = "Votre profil a été mis à jour avec succès."
            redirect_to teacher_profile_path
          end
        end
      else
        if is_avatar_upload
          format.turbo_stream do
            flash.now[:alert] = "Erreur lors de la mise à jour du profil : #{@teacher.errors.full_messages.join(', ')}"
            render :show, status: :unprocessable_entity
          end
          format.html do
            flash[:alert] = "Erreur lors de la mise à jour du profil."
            render :show, status: :unprocessable_entity
          end
        else
          format.html do
            flash[:alert] = "Erreur lors de la mise à jour du profil."
            render :show, status: :unprocessable_entity
          end
        end
      end
    end
  end

  private

  def ensure_teacher!
    redirect_to root_path unless current_user&.teacher?
  end

  def create_teacher_if_missing
    return if current_user.teacher.present?

    # Créer un Teacher vide avec les valeurs minimales requises
    teacher = current_user.build_teacher(
      first_name: current_user.first_name.presence || "Prénom",
      last_name: current_user.last_name.presence || "Nom",
      display_name: build_display_name.presence || "Prénom N.",
      picture_visible: false,
      gender: :female, # Valeur par défaut, sera modifié dans le formulaire
      career_status: :certifie, # Valeur par défaut, sera modifié dans le formulaire
      email_pro: current_user.email,
      email_perso: current_user.email,
      status: :pending,
      rgpd_consent: false
    )

    unless teacher.save
      flash[:alert] = "Erreur lors de la création de votre profil. Veuillez réessayer."
      redirect_to root_path
      return
    end
  end

  def set_teacher
    @teacher = current_user.teacher
  end

  def build_display_name
    if current_user.first_name.present? && current_user.last_name.present?
      "#{current_user.first_name} #{current_user.last_name[0]}."
    elsif current_user.first_name.present?
      current_user.first_name
    else
      ""
    end
  end

  def teacher_params
    params.require(:teacher).permit(
      :first_name, :last_name, :gender,
      :academy_name, :school_name, :career_status,
      :base_city, :base_zip_code, :radius_text,
      :support_text, :experience_text, :special_skills_text,
      :interest_text, :exams_raw_text,
      :pricing_text, :target_students_range,
      :email_pro, :email_perso, :phone,
      :profile_image_url, :profile_image_attached, :rgpd_consent, :picture_visible,
      :avatar,
      subjects_tags: [], levels: [], exam_tags: [], pedagogy_tags: []
    )
  end
end
