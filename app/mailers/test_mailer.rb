class TestMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.test_mailer.ping.subject
  #
  def ping
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
