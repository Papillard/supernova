class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAIL_FROM", "noreply@prof-connect.fr") }
  layout "mailer"
  # Le garde-fou est implémenté dans config/initializers/disable_mailers_interceptor.rb
  # Devise::Mailer hérite de ActionMailer::Base, donc il n'est pas affecté par ce garde-fou
end
