module Notifications
  class RequestNotifier
    def self.call(request, event:)
      new(request, event).call
    end

    def initialize(request, event)
      @request = request
      @event = event.to_sym
    end

    def call
      case @event
      when :created
        NotificationMailer.new_request_to_teacher(@request.id).deliver_later
      when :accepted
        NotificationMailer.request_accepted_to_parent(@request.id).deliver_later
      when :declined
        NotificationMailer.request_declined_to_parent(@request.id).deliver_later
      end
    end
  end
end
