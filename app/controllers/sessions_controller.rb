class SessionsController < Devise::SessionsController
  private

  def after_sign_in_path_for(resource)
    if resource.parent?
      teachers_path
    elsif resource.teacher?
      dashboard_teacher_path
    else
      super
    end
  end
end
