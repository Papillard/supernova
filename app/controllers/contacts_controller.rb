class ContactsController < ApplicationController
  # Page publique : pas d'authentification requise.
  def new
    @contact_message = ContactMessage.new(prefill_from_user)
  end

  def create
    @contact_message = ContactMessage.new(contact_params)

    # Honeypot : on fait comme si tout s'était bien passé, sans envoyer.
    if @contact_message.spam?
      redirect_to contact_path, notice: t_success and return
    end

    if @contact_message.valid?
      ContactMailer.contact_email(@contact_message.attributes.except("company")).deliver_later
      redirect_to contact_path, notice: t_success
    else
      flash.now[:alert] = "Merci de corriger les champs indiqués."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_message).permit(:name, :email, :subject, :message, :company)
  end

  def prefill_from_user
    return {} unless user_signed_in?

    { name: current_user.first_name.presence || display_name_for(current_user),
      email: current_user.email }
  end

  def display_name_for(user)
    user.teacher&.display_name.presence ||
      user.parent_profile&.first_name.presence ||
      user.email.split("@").first
  end

  def t_success
    "Merci, votre message a bien été envoyé. Nous vous répondrons rapidement."
  end
end
