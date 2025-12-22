module Notifications
  class MessageNotifier
    def self.call(message)
      new(message).call
    end

    def initialize(message)
      @message = message
    end

    def call
      return if @message.system?
      return unless @message.persisted?

      @request = @message.request
      @sender = @message.user

      # Déterminer le destinataire (l'autre partie dans la request)
      recipient = if @sender == @request.parent
                    @request.teacher.user
                  else
                    @request.parent
                  end

      return unless email_notifications_enabled?(recipient)

      # Throttle check: ne pas envoyer si un email a été envoyé dans les 2 dernières minutes
      return if EmailEvent.exists?(
        kind: "new_message",
        request_id: @request.id,
        recipient_id: recipient.id,
        sent_at: 2.minutes.ago..
      )

      # Créer l'email event avant d'envoyer
      EmailEvent.create!(
        kind: "new_message",
        request_id: @request.id,
        recipient_id: recipient.id,
        sent_at: Time.current
      )

      NotificationMailer.new_message_to_other_party(@message.id).deliver_later
    end

    private

    def email_notifications_enabled?(user)
      # Vérifier si la colonne existe (pour compatibilité avant migration)
      return true unless user.attributes.key?("email_notifications_enabled")
      user.email_notifications_enabled?
    end
  end
end
