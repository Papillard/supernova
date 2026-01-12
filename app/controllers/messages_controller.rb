class MessagesController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!
  before_action :set_request

  def create
    @message = Message.new(message_params)
    @message.request = @request
    @message.user = current_user
    @message.system = false
    authorize @message

    respond_to do |format|
      if @message.save
        format.turbo_stream
        format.html do
          if current_user.parent? && @request.parent_id == current_user.id
            redirect_to requests_path(id: @request.id), notice: "Message envoyé."
          elsif current_user.teacher? && @request.teacher_id == current_user.teacher.id
            redirect_to teacher_requests_path(id: @request.id), notice: "Message envoyé."
          else
            redirect_to root_path, alert: "Erreur de redirection."
          end
        end
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message-form-#{@request.id}", partial: "messages/form", locals: { request: @request, message: @message }) }
        format.html do
          if current_user.parent? && @request.parent_id == current_user.id
            redirect_to requests_path(id: @request.id), alert: "Erreur lors de l'envoi du message."
          elsif current_user.teacher? && @request.teacher_id == current_user.teacher.id
            redirect_to teacher_requests_path(id: @request.id), alert: "Erreur lors de l'envoi du message."
          else
            redirect_to root_path, alert: "Erreur lors de l'envoi du message."
          end
        end
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end

  def set_request
    @request = Request.find(params[:request_id])
  end
end
