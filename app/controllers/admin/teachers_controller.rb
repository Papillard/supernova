module Admin
  class TeachersController < ApplicationController
    layout "authenticated"
    before_action :authenticate_user!
    before_action :set_teacher, only: [:show, :edit, :update, :approve, :reject]

    rescue_from Pundit::NotAuthorizedError, with: :redirect_non_admin

    def index
      authorize [:admin, Teacher]
      @teachers = policy_scope([:admin, Teacher])
      @teachers = @teachers.where(status: params[:status]) if params[:status].present?
      @teachers = @teachers.order(created_at: :desc)
    end

    def show
      authorize [:admin, @teacher]
    end

    def edit
      authorize [:admin, @teacher]
    end

    def update
      authorize [:admin, @teacher]
      params_hash = teacher_params.to_h
      normalize_array_params(params_hash)

      # Handle avatar upload
      if params[:teacher].present? && params[:teacher][:avatar].present?
        avatar_file = params[:teacher][:avatar]

        allowed_types = %w[image/jpeg image/jpg image/png]
        unless avatar_file.respond_to?(:content_type) && allowed_types.include?(avatar_file.content_type)
          flash[:alert] = "Format d'image non supporté. Veuillez utiliser JPEG ou PNG."
          render :edit, status: :unprocessable_entity
          return
        end

        begin
          if ENV["CLOUDINARY_URL"].present?
            Cloudinary.config_from_url(ENV["CLOUDINARY_URL"]) if Cloudinary.config.cloud_name.blank?

            file_to_upload = avatar_file.respond_to?(:tempfile) ? avatar_file.tempfile : avatar_file
            upload_result = Cloudinary::Uploader.upload(file_to_upload, {
              folder: "profconnect/teachers",
              resource_type: "image"
            })

            if upload_result && upload_result["secure_url"].present?
              params_hash[:profile_image_url] = upload_result["secure_url"]
              params_hash[:profile_image_attached] = true
            else
              flash[:alert] = "Erreur lors de l'upload : réponse invalide de Cloudinary."
              render :edit, status: :unprocessable_entity
              return
            end
          end
        rescue => e
          Rails.logger.error "Cloudinary upload error: #{e.class} - #{e.message}"
          flash[:alert] = "Erreur lors de l'upload de la photo : #{e.message}"
          render :edit, status: :unprocessable_entity
          return
        end
      end

      params_hash.delete(:avatar)

      if @teacher.update(params_hash)
        redirect_to admin_teacher_path(@teacher), notice: "Le profil a été mis à jour."
      else
        flash.now[:alert] = "Erreur : #{@teacher.errors.full_messages.join(', ')}"
        render :edit, status: :unprocessable_entity
      end
    end

    def approve
      authorize [:admin, @teacher]
      if @teacher.update(status: :approved)
        display_name = "#{@teacher.first_name} #{@teacher.last_name[0].upcase}" if @teacher.first_name.present? && @teacher.last_name.present?
        display_name ||= @teacher.first_name if @teacher.first_name.present?
        display_name ||= "Professeur"
        flash[:notice] = "Le professeur #{display_name} a été approuvé."
      else
        flash[:alert] = "Erreur lors de l'approbation."
      end
      redirect_to admin_teacher_path(@teacher)
    end

    def reject
      authorize [:admin, @teacher]
      if @teacher.update(status: :rejected)
        display_name = "#{@teacher.first_name} #{@teacher.last_name[0].upcase}" if @teacher.first_name.present? && @teacher.last_name.present?
        display_name ||= @teacher.first_name if @teacher.first_name.present?
        display_name ||= "Professeur"
        flash[:notice] = "Le professeur #{display_name} a été refusé."
      else
        flash[:alert] = "Erreur lors du refus."
      end
      redirect_to admin_teacher_path(@teacher)
    end

    private

    def set_teacher
      @teacher = Teacher.find(params[:id])
    end

    def redirect_non_admin
      redirect_to root_path, alert: "Accès réservé aux administrateurs."
    end

    def teacher_params
      params.require(:teacher).permit(
        :first_name, :last_name, :gender, :career_status,
        :academy_name, :school_name,
        :headline, :primary_subject, :about_me, :pricing_text,
        :city, :zip_code, :target_students_range,
        :status, :rgpd_consent,
        :profile_image_url, :profile_image_attached, :avatar,
        :served_zones,
        subjects_tags: [], levels: [], exam_tags: [],
        specific_support: [], teaching_formats: [], target_audience_tags: []
      )
    end

    def normalize_array_params(params_hash)
      # Normalize served_zones (can arrive as JSON string)
      if params_hash[:served_zones].is_a?(String)
        begin
          parsed = JSON.parse(params_hash[:served_zones])
          params_hash[:served_zones] = parsed.is_a?(Array) ? parsed.reject(&:blank?) : []
        rescue JSON::ParserError
          params_hash[:served_zones] = []
        end
      elsif params_hash[:served_zones].is_a?(Array)
        params_hash[:served_zones] = params_hash[:served_zones].reject(&:blank?)
      else
        params_hash[:served_zones] = []
      end

      # Normalize target_audience_tags (can arrive as JSON string)
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

      # Normalize other array fields
      %w[subjects_tags levels exam_tags specific_support].each do |field|
        unless params_hash[field].is_a?(Array)
          params_hash[field] = params_hash[field].present? ? Array(params_hash[field]) : []
        end
        params_hash[field] = params_hash[field].reject(&:blank?)
      end

      params_hash[:teaching_formats] = params[:teacher][:teaching_formats].present? ?
        Array(params[:teacher][:teaching_formats]).reject(&:blank?) : []

      # Limit target_audience_tags to 2
      if params_hash[:target_audience_tags].present? && params_hash[:target_audience_tags].length > 2
        params_hash[:target_audience_tags] = params_hash[:target_audience_tags].first(2)
      end

      # Normalize career_status
      if params_hash.key?(:career_status) && params_hash[:career_status].present?
        raw = params_hash[:career_status].to_s.strip
        valid_values = Teacher::CAREER_STATUS_VALUES.values
        normalized = {
          "certifié" => "certifie", "certifie" => "certifie",
          "agrégé" => "agrege", "agrege" => "agrege",
          "prof des écoles" => "prof_des_ecoles", "prof_des_ecoles" => "prof_des_ecoles",
          "autre" => "autre"
        }[raw.downcase] || (valid_values.include?(raw) ? raw : nil)

        if normalized && valid_values.include?(normalized)
          params_hash[:career_status] = normalized
        else
          params_hash.delete(:career_status)
        end
      end

      # Clean empty strings to nil for text fields
      params_hash.each do |key, value|
        if value.is_a?(String) && value.empty? && !%w[subjects_tags levels exam_tags specific_support teaching_formats target_audience_tags served_zones].include?(key.to_s)
          params_hash[key] = nil
        end
      end
    end
  end
end
