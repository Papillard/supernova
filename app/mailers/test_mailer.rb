class TestMailer < ApplicationMailer
  def ping(to)
    mail(
      to: to,
      subject: "ProfConnect SMTP OK",
      body: "ping"
    )
  end
end
