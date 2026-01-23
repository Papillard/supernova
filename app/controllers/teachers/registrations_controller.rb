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

    email = sign_up_params[:email]

    # Validation : exclure les emails académiques (@ac-*)
    if email.present? && email.match?(/@ac-.*\.fr$/i)
      build_resource(sign_up_params.merge(role: "teacher"))
      resource.errors.add(:email, "Les emails académiques (@ac-*.fr) ne sont pas acceptés. Veuillez utiliser votre email personnel.")
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
      return
    end

    # Chercher un Teacher (pending ou approved) qui a cet email dans email_pro OU email_perso
    # Cas du lancement : early adopters créés via seeds qui s'inscrivent
    teacher = Teacher.where("email_pro = ? OR email_perso = ?", email, email).first

    if teacher
      existing_user = teacher.user
      was_pending = teacher.pending?

      # Mettre à jour l'email du User avec l'email de signup
      existing_user.email = email

      # Mettre à jour email_pro ou email_perso selon lequel correspond
      if teacher.email_pro == email
        teacher.email_perso = email if teacher.email_perso.blank?
      elsif teacher.email_perso == email
        teacher.email_pro = email if teacher.email_pro.blank?
      end

      # Mettre à jour le mot de passe et l'email du user
      if existing_user.update(
        email: email,
        password: sign_up_params[:password],
        password_confirmation: sign_up_params[:password_confirmation]
      )
        # Mettre à jour rgpd_consent
        teacher.update(rgpd_consent: true)

        # Si pending, approuver (le callback enverra le mail automatiquement)
        if was_pending
          teacher.update(status: :approved)
        else
          # Si déjà approved, envoyer le mail de welcome directement
          Notifications::WelcomeNotifier.call(existing_user)
        end

        sign_in(existing_user)
        set_flash_message! :notice, :signed_up
        respond_with existing_user, location: after_sign_up_path_for(existing_user)
        return
      else
        build_resource(sign_up_params.merge(role: "teacher"))
        resource.errors.merge!(existing_user.errors)
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
        return
      end
    end

    build_resource(sign_up_params.merge(role: "teacher"))

    resource.save
    yield resource if block_given?

    if resource.persisted?
      # Créer le Teacher avec rgpd_consent = true (les checkboxes ont été validées)
      if resource.teacher.nil?
        teacher = resource.build_teacher(
          first_name: resource.first_name.presence || "Prénom",
          last_name: resource.last_name.presence || "Nom",
          display_name: resource.first_name.present? && resource.last_name.present? ? "#{resource.first_name} #{resource.last_name[0].upcase}." : (resource.first_name || "Prénom N."),
          email_pro: resource.email,
          email_perso: resource.email,
          status: :pending,
          rgpd_consent: true # Les checkboxes ont été validées
        )

        unless teacher.save
          Rails.logger.error "Erreur lors de la création du teacher: #{teacher.errors.full_messages.join(', ')}"
          resource.errors.add(:base, "Erreur lors de la création du profil professeur : #{teacher.errors.full_messages.join(', ')}")
          clean_up_passwords resource
          set_minimum_password_length
          respond_with resource
          return
        end

        Rails.logger.info "Teacher créé avec succès pour user #{resource.id}"
      end

      # Connecter l'utilisateur et rediriger (sign_up gère les emails transactionnels)
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        # Utiliser status: :see_other pour forcer une vraie redirection HTTP même depuis Turbo
        redirect_to after_sign_up_path_for(resource), status: :see_other
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        redirect_to after_inactive_sign_up_path_for(resource), status: :see_other
      end
    else
      Rails.logger.error "Erreur lors de la création du user: #{resource.errors.full_messages.join(', ')}"
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def after_sign_up_path_for(resource)
    teacher_profile_path
  end
end
