class AccountsController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!

  def edit
    @user = current_user
    @minimum_password_length = Devise.password_length.min
  end

  def update
    @user = current_user
    @minimum_password_length = Devise.password_length.min

    # Déterminer quelle action est demandée
    if params[:update_type] == "email"
      update_email
    elsif params[:update_type] == "password"
      update_password
    else
      redirect_to account_path, alert: "Action non reconnue."
    end
  end

  private

  def update_email
    email_params = params.require(:user).permit(:email, :current_password)
    
    if email_params[:current_password].blank?
      @user.errors.add(:current_password, "est requis pour modifier votre email")
      render :edit, status: :unprocessable_entity
      return
    end

    # Utiliser update_with_password pour vérifier le current_password
    if @user.update_with_password(email_params)
      sign_in(@user)
      redirect_to account_path, notice: "Votre email a été mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_password
    password_params = params.require(:user).permit(:password, :password_confirmation, :current_password)
    
    if password_params[:current_password].blank?
      @user.errors.add(:current_password, "est requis pour modifier votre mot de passe")
      render :edit, status: :unprocessable_entity
      return
    end

    if password_params[:password].blank? || password_params[:password_confirmation].blank?
      @user.errors.add(:password, "et la confirmation sont requis pour changer le mot de passe")
      render :edit, status: :unprocessable_entity
      return
    end

    # Utiliser update_with_password pour vérifier le current_password
    if @user.update_with_password(password_params)
      sign_in(@user)
      redirect_to account_path, notice: "Votre mot de passe a été mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
