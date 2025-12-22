# Interceptor pour bloquer tous les envois d'emails en production si DISABLE_MAILERS=1
# Exception explicite pour Devise::Mailer (emails critiques comme reset password)
class DisableMailersInterceptor
  def self.delivering_email(message)
    # Ne bloquer qu'en production
    return unless Rails.env.production?

    # Ne pas bloquer Devise::Mailer (emails critiques)
    # Le mailer est accessible via message.delivery_handler
    mailer = message.delivery_handler
    return if mailer.is_a?(Devise::Mailer)

    # Bloquer si DISABLE_MAILERS=1
    if ENV["DISABLE_MAILERS"] == "1"
      message.perform_deliveries = false
    end
  end
end

# Enregistrer l'interceptor pour tous les mailers
# L'interceptor vérifie explicitement si c'est Devise::Mailer et le bypass
ActionMailer::Base.register_interceptor(DisableMailersInterceptor)
