module Notifications
  class WelcomeNotifier
    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      return unless @user.persisted?

      # Pour les parents, envoyer immédiatement à l'inscription
      # Pour les teachers, l'email sera envoyé quand le profil est approuvé (via Teacher callback)
      if @user.parent?
        NotificationMailer.welcome_parent(@user.id).deliver_later
      elsif @user.teacher?
        # Vérifier si le teacher est déjà approuvé
        teacher = @user.teacher
        if teacher&.status == "approved"
          NotificationMailer.welcome_teacher(@user.id).deliver_later
        end
      end
    end
  end
end
