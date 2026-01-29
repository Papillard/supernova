class TeacherProfilesController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :create_teacher_if_missing
  before_action :set_teacher

  def show
    authorize @teacher, :edit?
    render :show, formats: [:html]
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
        if value.is_a?(String) && value.empty? && !%w[subjects_tags levels exam_tags specific_support teaching_formats target_audience_tags served_zones].include?(key.to_s)
          params_hash[key] = nil
        end
      end
      
      # Mettre à jour le teacher avec tous les params (career_status est déjà normalisé)
      update_success = @teacher.update(params_hash)
      
      if update_success
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
    # Si l'utilisateur s'est inscrit via le formulaire, rgpd_consent devrait être true
    # Sinon, on le met à false par défaut (cas d'un compte créé autrement)
    teacher = current_user.build_teacher(
      first_name: current_user.first_name.presence || "Prénom",
      last_name: current_user.last_name.presence || "Nom",
      display_name: build_display_name.presence || "Prénom N.",
      email_pro: current_user.email,
      email_perso: current_user.email,
      status: :pending,
      rgpd_consent: true # Par défaut true car si l'utilisateur accède au profil, c'est qu'il s'est inscrit via le formulaire
    )

    unless teacher.save
      Rails.logger.error "Erreur lors de la création du teacher: #{teacher.errors.full_messages.join(', ')}"
      flash[:alert] = "Erreur lors de la création de votre profil. Veuillez réessayer."
      redirect_to root_path
      return
    end

    # Recharger l'utilisateur pour que l'association teacher soit disponible
    current_user.reload
  end

  def set_teacher
    @teacher = current_user.reload.teacher
    unless @teacher
      flash[:alert] = "Votre profil professeur n'a pas pu être chargé. Veuillez réessayer."
      redirect_to root_path
      return
    end
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
      params_hash[:profile_image_url] = teacher_params[:profile_image_url] if teacher_params[:profile_image_url].present?
      params_hash[:profile_image_attached] = teacher_params[:profile_image_attached] if teacher_params[:profile_image_attached].present?
    end

    params_hash
  end

  def parse_checkbox_value(value)
    return false if value.blank?

    actual_value = value.is_a?(Array) ? value.last : value
    actual_value.to_s == "1" || actual_value.to_s == "true" || actual_value == true
  end

  def normalize_array_params(params_hash)
    # Normaliser served_zones si c'est une string JSON (AVANT de faire Array())
    if params_hash[:served_zones].is_a?(String)
      begin
        parsed = JSON.parse(params_hash[:served_zones])
        params_hash[:served_zones] = parsed.is_a?(Array) ? parsed.reject(&:blank?) : []
      rescue JSON::ParserError
        params_hash[:served_zones] = []
      end
    elsif params_hash[:served_zones].is_a?(Array)
      # Si c'est déjà un array, juste nettoyer les valeurs vides
      params_hash[:served_zones] = params_hash[:served_zones].reject(&:blank?)
    else
      params_hash[:served_zones] = []
    end

    # Normaliser target_audience_tags si c'est une string JSON (AVANT de faire Array())
    if params_hash[:target_audience_tags].is_a?(String)
      begin
        parsed = JSON.parse(params_hash[:target_audience_tags])
        params_hash[:target_audience_tags] = parsed.is_a?(Array) ? parsed.reject(&:blank?) : []
      rescue JSON::ParserError
        params_hash[:target_audience_tags] = []
      end
    elsif params_hash[:target_audience_tags].is_a?(Array)
      params_hash[:target_audience_tags] = params_hash[:target_audience_tags].reject(&:blank?)
    else
      params_hash[:target_audience_tags] = []
    end

    # Normaliser les autres champs array et rejeter les valeurs vides
    %w[subjects_tags levels exam_tags specific_support].each do |field|
      # Si ce n'est pas déjà un array, le convertir
      unless params_hash[field].is_a?(Array)
        params_hash[field] = params_hash[field].present? ? Array(params_hash[field]) : []
      end
      # Rejeter les valeurs vides
      params_hash[field] = params_hash[field].reject(&:blank?)
    end

    params_hash[:teaching_formats] = params[:teacher][:teaching_formats].present? ?
      Array(params[:teacher][:teaching_formats]).reject(&:blank?) : []

    # Valider et filtrer les valeurs pour ne garder que celles qui sont dans les listes d'options
    validate_and_filter_array_values(params_hash)

    # Limiter target_audience_tags à 2 éléments maximum
    if params_hash[:target_audience_tags].present? && params_hash[:target_audience_tags].length > 2
      params_hash[:target_audience_tags] = params_hash[:target_audience_tags].first(2)
    end

    # Normaliser career_status vers les clés stockées en DB (certifie, agrege, etc.)
    # On stocke les clés sans accent en DB, l'affichage avec accent est géré dans les helpers
    if params_hash.key?(:career_status)
      raw_value = params_hash[:career_status]
      
      if raw_value.present?
        raw_value = raw_value.to_s.strip
        
        # Récupérer les valeurs valides (clés) depuis le modèle
        valid_values = Teacher::CAREER_STATUS_VALUES.values
        valid_keys = Teacher::CAREER_STATUS_VALUES.keys.map(&:to_s)
        
        # Normaliser vers une clé valide
        normalized_value = if valid_values.include?(raw_value) || valid_keys.include?(raw_value.downcase)
          raw_value.downcase
        else
          # Mapping pour convertir les valeurs avec accent vers les clés (rétrocompatibilité)
          {
            "certifié" => "certifie",
            "certifie" => "certifie",
            "agrégé" => "agrege",
            "agrege" => "agrege",
            "prof des écoles" => "prof_des_ecoles",
            "prof_des_ecoles" => "prof_des_ecoles",
            "autre" => "autre"
          }[raw_value.downcase]
        end
        
        if normalized_value && valid_values.include?(normalized_value)
          params_hash[:career_status] = normalized_value
        else
          Rails.logger.error "Career status value '#{raw_value}' is not valid. Valid values: #{valid_values.inspect}"
          params_hash.delete(:career_status)
        end
      else
        params_hash[:career_status] = nil
      end
    end
  end

  def validate_and_filter_array_values(params_hash)
    # Extraire les valeurs valides des constantes
    valid_exam_tags = TeachersHelper::EXAM_TAGS_OPTIONS.map { |_, value| value }
    valid_specific_support = TeachersHelper::SPECIFIC_SUPPORT_OPTIONS.map { |_, value| value }
    valid_target_audience_tags = TeachersHelper::TARGET_AUDIENCE_TAGS_OPTIONS.map { |_, value| value }
    valid_subjects = TeachersHelper::SUBJECTS_OPTIONS.map { |_, value| value }
    valid_levels = TeachersHelper::LEVELS_OPTIONS.map { |_, value| value }
    valid_teaching_formats = ["online", "at_student_home", "at_teacher_home"]

    # Filtrer exam_tags pour ne garder que les valeurs valides
    if params_hash[:exam_tags].is_a?(Array)
      params_hash[:exam_tags] = params_hash[:exam_tags].select { |tag| valid_exam_tags.include?(tag.to_s) }
    end

    # Filtrer specific_support pour ne garder que les valeurs valides
    if params_hash[:specific_support].is_a?(Array)
      params_hash[:specific_support] = params_hash[:specific_support].select { |tag| valid_specific_support.include?(tag.to_s) }
    end

    # Filtrer target_audience_tags pour ne garder que les valeurs valides
    if params_hash[:target_audience_tags].is_a?(Array)
      params_hash[:target_audience_tags] = params_hash[:target_audience_tags].select { |tag| valid_target_audience_tags.include?(tag.to_s) }
    end

    # Filtrer subjects_tags pour ne garder que les valeurs valides
    if params_hash[:subjects_tags].is_a?(Array)
      params_hash[:subjects_tags] = params_hash[:subjects_tags].select { |tag| valid_subjects.include?(tag.to_s) }
    end

    # Filtrer levels pour ne garder que les valeurs valides
    if params_hash[:levels].is_a?(Array)
      params_hash[:levels] = params_hash[:levels].select { |level| valid_levels.include?(level.to_s) }
    end

    # Filtrer teaching_formats pour ne garder que les valeurs valides
    if params_hash[:teaching_formats].is_a?(Array)
      params_hash[:teaching_formats] = params_hash[:teaching_formats].select { |format| valid_teaching_formats.include?(format.to_s) }
    end
  end

  def teacher_params
    # Permettre served_zones comme string ou array car il peut arriver comme JSON string
    permitted = params.require(:teacher).permit(
      :first_name, :last_name, :gender,
      :academy_name, :school_name, :career_status,
      :zip_code, :city,
      :about_me, :headline, :primary_subject, :exams_raw_text,
      :pricing_text, :target_students_range,
      :email_pro, :email_perso, :phone,
      :profile_image_url, :profile_image_attached,
      :avatar,
      :served_zones,
      subjects_tags: [], levels: [], exam_tags: [], specific_support: [], teaching_formats: [], target_audience_tags: []
    )
    
    permitted
  end
end
