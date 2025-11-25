class SessionsController < Devise::SessionsController
  private

  def after_sign_in_path_for(resource)
    if resource.parent?
      teachers_path
    elsif resource.teacher?
      teacher_profile_path
    else
      super
    end
  end
end
