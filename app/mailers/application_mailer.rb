class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAIL_FROM", "noreply@prof-connect.fr") }
  layout "mailer"
end
