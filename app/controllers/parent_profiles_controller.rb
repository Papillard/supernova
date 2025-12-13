class ParentProfilesController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :ensure_parent_role!
  before_action :set_parent_profile

  def show
    # Display the profile form
  end

  def complete
    # Profile completion page - can be skipped
    @parent_profile = current_user.parent_profile || current_user.build_parent_profile
    @parent_profile.save! unless @parent_profile.persisted?
  end

  def update
    is_avatar_only = params[:avatar_only].present?
    params_hash = parent_profile_params.to_h

    # Si c'est un upload d'avatar uniquement, ne traiter que les champs avatar
    if is_avatar_only
      params_hash = params_hash.slice(:profile_image_url)
    end

    # Gérer l'upload d'avatar
    if params[:parent_profile].present? && params[:parent_profile][:avatar].present?
      avatar_file = params[:parent_profile][:avatar]

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
        file_to_upload = if avatar_file.respond_to?(:tempfile)
          avatar_file.tempfile
        elsif avatar_file.respond_to?(:path) && File.exist?(avatar_file.path)
          avatar_file
        else
          avatar_file
        end

        upload_result = Cloudinary::Uploader.upload(file_to_upload, {
          folder: "profconnect/parents",
          resource_type: "image"
        })

        if upload_result && upload_result["secure_url"].present?
          params_hash[:profile_image_url] = upload_result["secure_url"]
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
    params_hash.delete(:avatar)

    @is_avatar_upload = is_avatar_only || (params[:parent_profile].present? && params[:parent_profile][:avatar].present?)

    respond_to do |format|
      if @parent_profile.update(params_hash)
        # Recharger le parent_profile pour avoir le statut de completion à jour
        @parent_profile.reload
        format.turbo_stream { render :update }
        format.html do
          flash[:notice] = @is_avatar_upload ? "Photo de profil mise à jour avec succès." : "Infos enregistrées"
          redirect_to parent_profile_path
        end
      else
        if @is_avatar_upload
          format.turbo_stream do
            flash.now[:alert] = "Erreur lors de la mise à jour du profil : #{@parent_profile.errors.full_messages.join(', ')}"
            render :show, status: :unprocessable_entity
          end
          format.html do
            flash[:alert] = "Erreur lors de la mise à jour du profil."
            render :show, status: :unprocessable_entity
          end
        else
          format.turbo_stream do
            flash.now[:alert] = "Erreur lors de la mise à jour : #{@parent_profile.errors.full_messages.join(', ')}"
            render :show, status: :unprocessable_entity
          end
          format.html do
            flash[:alert] = "Erreur lors de la mise à jour du profil : #{@parent_profile.errors.full_messages.join(', ')}"
            render :show, status: :unprocessable_entity
          end
        end
      end
    end
  end

  private

  def ensure_parent_role!
    redirect_to root_path, alert: "Accès réservé aux parents." unless current_user&.parent?
  end

  def set_parent_profile
    @parent_profile = current_user.parent_profile || current_user.build_parent_profile
    @parent_profile.save! unless @parent_profile.persisted?
  end

  def parent_profile_params
    params.require(:parent_profile).permit(
      :first_name, :last_name, :address, :zip_code, :city,
      :profile_image_url, :avatar
    )
  end
end
