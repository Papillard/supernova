class ContactMailer < ApplicationMailer
  def contact_email(attrs)
    @name    = attrs["name"]
    @email   = attrs["email"]
    @subject = attrs["subject"]
    @message = attrs["message"]

    mail(
      to: ENV.fetch("CONTACT_EMAIL", "contact@prof-connect.fr"),
      reply_to: @email,
      subject: "[Contact ProfConnect] #{@subject}"
    )
  end
end
