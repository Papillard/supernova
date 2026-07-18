# Form object (ActiveModel, sans persistance en base) pour la page « Nous contacter ».
# Voir app/controllers/contacts_controller.rb et app/mailers/contact_mailer.rb.
class ContactMessage
  include ActiveModel::Model

  # company = honeypot anti-spam (champ caché, doit rester vide).
  attr_accessor :name, :email, :subject, :message, :company

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "n'est pas valide" }
  validates :subject, presence: true, length: { maximum: 150 }
  validates :message, presence: true, length: { minimum: 10, maximum: 5000 }

  # Rempli => bot. Le controller traite ça comme un faux succès silencieux.
  def spam?
    company.present?
  end

  # Clés en chaîne pour rester cohérent avec le mailer (attrs["name"], etc.).
  def attributes
    {
      "name" => name,
      "email" => email,
      "subject" => subject,
      "message" => message,
      "company" => company
    }
  end
end
