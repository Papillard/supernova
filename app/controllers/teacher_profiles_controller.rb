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
    params_hash = teacher_params.to_h

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

    if @teacher.update(params_hash)
      flash[:notice] = "Votre profil a été mis à jour avec succès."
      redirect_to teacher_profile_path
    else
      flash[:alert] = "Erreur lors de la mise à jour du profil."
      render :show, status: :unprocessable_entity
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
      :profile_image_url, :rgpd_consent, :picture_visible,
      subjects_tags: [], levels: [], exam_tags: [], pedagogy_tags: []
    )
  end
end
