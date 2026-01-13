class SessionsController < Devise::SessionsController
  private

  def after_sign_in_path_for(resource)
    if resource.parent?
      teachers_path
    elsif resource.teacher?
      teacher_redirect_path(resource.teacher)
    else
      super
    end
  end

  # Redirect logic pour les profs après sign in:
  # - Si profil incomplet → Mon profil
  # - Si status != approved (pending/rejected) → Mon profil
  # - Sinon → Mes demandes
  def teacher_redirect_path(teacher)
    if !teacher.profile_completed? || !teacher.approved?
      teacher_profile_path
    else
      teacher_requests_path
    end
  end
end
