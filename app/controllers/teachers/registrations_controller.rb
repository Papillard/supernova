class Teachers::RegistrationsController < Devise::RegistrationsController
  def create
    # Validation des checkboxes légales obligatoires
    unless params[:user] && params[:user][:accept_cgs] == "1" && params[:user][:accept_privacy_policy] == "1"
      build_resource(sign_up_params.merge(role: "teacher"))
      resource.errors.add(:base, "Vous devez accepter les Conditions Générales de Services et la Politique de confidentialité pour créer un compte.")
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
      return
    end

    build_resource(sign_up_params.merge(role: "teacher"))

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def after_sign_up_path_for(resource)
    teacher_profile_path
  end
end
