class NotificationMailer < ApplicationMailer
  def welcome_parent(user_id)
    @user = User.find(user_id)
    return unless email_notifications_enabled?(@user)
    return unless @user.parent?

    @parent_profile = @user.parent_profile
    @parent_first_name = @parent_profile&.first_name || @user.first_name || @user.email.split("@").first

    mail(
      to: @user.email,
      subject: "Bienvenue chez ProfConnect ! Trouvez votre professeur diplômé."
    )
  end

  def welcome_teacher(user_id)
    @user = User.find(user_id)
    return unless email_notifications_enabled?(@user)
    return unless @user.teacher?

    @teacher = @user.teacher
    @civility = case @teacher.gender
                when "male"
                  "M."
                when "female"
                  "Mme"
                else
                  ""
                end

    mail(
      to: @user.email,
      subject: "Bienvenue cher(chère) Professeur(e) ! Votre profil est en ligne."
    )
  end

  def new_request_to_teacher(request_id)
    @request = Request.find(request_id)
    @teacher = @request.teacher
    @user = @teacher.user
    return unless email_notifications_enabled?(@user)

    @parent = @request.parent
    @parent_profile = @parent.parent_profile
    @family_name = @parent_profile&.last_name || @parent.last_name || @parent.email
    @student = @request.student || @parent_profile&.students&.first
    @student_name = @student&.first_name || "un élève"
    @level = @request.level
    @subject = @request.subject
    @request_text_preview = truncate_text(@request.request_text, 200)

    @civility = case @teacher.gender
                when "male"
                  "M."
                when "female"
                  "Mme"
                else
                  ""
                end

    mail(
      to: @user.email,
      subject: "🔔 Nouvelle demande de mise en relation d'un(e) élève (#{@subject})"
    )
  end

  def request_accepted_to_parent(request_id)
    @request = Request.find(request_id)
    @parent = @request.parent
    return unless email_notifications_enabled?(@parent)

    @parent_profile = @parent.parent_profile
    @parent_first_name = @parent_profile&.first_name || @parent.first_name || @parent.email.split("@").first

    @teacher = @request.teacher
    @teacher_first_name = @teacher.first_name
    @subject = @request.subject

    @student = @request.student || @parent_profile&.students&.first
    @student_name = @student&.first_name || "votre enfant"

    mail(
      to: @parent.email,
      subject: "Bonne nouvelle ! #{@teacher_first_name} a accepté votre demande de cours."
    )
  end

  def request_declined_to_parent(request_id)
    @request = Request.find(request_id)
    @parent = @request.parent
    return unless email_notifications_enabled?(@parent)

    @parent_profile = @parent.parent_profile
    @parent_first_name = @parent_profile&.first_name || @parent.first_name || @parent.email.split("@").first

    @teacher = @request.teacher
    @teacher_first_name = @teacher.first_name

    mail(
      to: @parent.email,
      subject: "Réponse à votre demande de cours"
    )
  end

  def new_message_to_other_party(message_id)
    @message = Message.find(message_id)
    return if @message.system?

    @request = @message.request
    @sender = @message.user

    # Déterminer le destinataire (l'autre partie dans la request)
    if @sender == @request.parent
      # Le parent a envoyé, donc le destinataire est le prof
      @recipient = @request.teacher.user
      @recipient_profile = @request.teacher
      @sender_name = @request.parent.parent_profile&.first_name || @request.parent.first_name || @request.parent.email.split("@").first
      @is_parent_sender = true
    else
      # Le prof a envoyé, donc le destinataire est le parent
      @recipient = @request.parent
      @recipient_profile = @request.parent.parent_profile
      @sender_name = @request.teacher.first_name
      @is_parent_sender = false
    end

    @message_preview = truncate_text(@message.body, 200)

    if @is_parent_sender
      # Email au prof
      @civility = case @request.teacher.gender
                  when "male"
                    "M."
                  when "female"
                    "Mme"
                  else
                    ""
                  end
      subject = "Nouveau message de #{@sender_name} sur ProfConnect"
    else
      # Email au parent
      subject = "Nouveau message de #{@sender_name} sur ProfConnect"
    end

    mail(
      to: @recipient.email,
      subject: subject
    )
  end

  private

  def email_notifications_enabled?(user)
    # Vérifier si la colonne existe (pour compatibilité avant migration)
    return true unless user.attributes.key?("email_notifications_enabled")
    user.email_notifications_enabled?
  end

  def truncate_text(text, length)
    return "" if text.blank?
    text.length > length ? "#{text[0...length]}..." : text
  end
end
