class TeacherProfilesController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :create_teacher_if_missing
  before_action :set_teacher

  def show
    authorize @teacher
  end

  def update
    authorize @teacher
    is_avatar_only = params[:avatar_only].present?

    if is_avatar_only
      params_hash = build_avatar_params
    else
      params_hash = teacher_params.to_h
      normalize_array_params(params_hash)
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
      # Nettoyer les valeurs vides (convertir "" en nil pour les champs texte)
      params_hash.each do |key, value|
        if value.is_a?(String) && value.empty? && !%w[subjects_tags levels exam_tags pedagogy_tags teaching_formats].include?(key.to_s)
          params_hash[key] = nil
        end
      end

      if @teacher.update(params_hash)
        # Recharger pour avoir les données à jour depuis la DB
        @teacher.reload

        if is_avatar_upload
          flash.now[:notice] = "Photo de profil mise à jour."
          format.turbo_stream { render :update }
          format.html { redirect_to teacher_profile_path, notice: "Photo de profil mise à jour avec succès." }
        elsif params[:stay_on_page].present?
          @current_tab = params[:current_tab] || "infos-basiques"
          flash.now[:notice] = "Modifications enregistrées."
          format.turbo_stream { render :update_step }
          format.html do
            flash[:notice] = "Votre profil a été mis à jour avec succès."
            redirect_to teacher_profile_path(current_tab: @current_tab)
          end
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
        # En cas d'erreur, rester sur la page avec les erreurs affichées
        if params[:stay_on_page].present?
          @current_tab = params[:current_tab] || "infos-basiques"
          format.turbo_stream do
            flash.now[:alert] = "Erreur lors de la mise à jour : #{@teacher.errors.full_messages.join(', ')}"
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
  end

  private

  def create_teacher_if_missing
    return unless current_user&.teacher?
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

  def build_avatar_params
    params_hash = {}

    if params[:teacher].present?
      teacher_params = params[:teacher]
      params_hash[:picture_visible] = parse_checkbox_value(teacher_params[:picture_visible])
      params_hash[:profile_image_url] = teacher_params[:profile_image_url] if teacher_params[:profile_image_url].present?
      params_hash[:profile_image_attached] = teacher_params[:profile_image_attached] if teacher_params[:profile_image_attached].present?
    else
      params_hash[:picture_visible] = false
    end

    params_hash
  end

  def parse_checkbox_value(value)
    return false if value.blank?

    actual_value = value.is_a?(Array) ? value.last : value
    actual_value.to_s == "1" || actual_value.to_s == "true" || actual_value == true
  end

  def normalize_array_params(params_hash)
    %w[subjects_tags levels exam_tags pedagogy_tags].each do |field|
      params_hash[field] = params_hash[field].present? ? Array(params_hash[field]).reject(&:blank?) : []
    end

    params_hash[:teaching_formats] = params[:teacher][:teaching_formats].present? ?
      Array(params[:teacher][:teaching_formats]).reject(&:blank?) : []

    # Convertir career_status de la valeur string vers la clé d'enum
    if params_hash[:career_status].present?
      career_status_mapping = {
        "certifié" => :certifie,
        "agrégé" => :agrege,
        "prof des écoles" => :prof_des_ecoles,
        "autre" => :autre
      }
      mapped_value = career_status_mapping[params_hash[:career_status]]
      params_hash[:career_status] = mapped_value if mapped_value
    end
  end

  def teacher_params
    params.require(:teacher).permit(
      :first_name, :last_name, :gender,
      :academy_name, :school_name, :career_status,
      :address, :zip_code, :city, :radius_text,
      :support_text, :experience_text, :special_skills_text,
      :interest_text, :exams_raw_text,
      :pricing_text, :target_students_range,
      :email_pro, :email_perso, :phone,
      :profile_image_url, :profile_image_attached, :rgpd_consent, :picture_visible,
      :avatar,
      subjects_tags: [], levels: [], exam_tags: [], pedagogy_tags: [], teaching_formats: []
    )
  end
end
