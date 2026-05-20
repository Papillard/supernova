module Admin
  class RequestsController < ApplicationController
    layout "authenticated"
    before_action :authenticate_user!

    rescue_from Pundit::NotAuthorizedError, with: :redirect_non_admin

    def index
      authorize [:admin, Request]
      @requests = policy_scope([:admin, Request])
                    .includes(:student, parent: :parent_profile, teacher: :user)
                    .order(Arel.sql("COALESCE(last_message_at, created_at) DESC"))
      @message_counts = Message.where(request_id: @requests.map(&:id)).group(:request_id).count
    end

    def show
      @request = Request.includes(:student, parent: :parent_profile, teacher: :user,
                                  messages: { user: [:teacher, :parent_profile] })
                        .find(params[:id])
      authorize [:admin, @request]
      @messages = @request.messages.order(:created_at)
    end

    private

    def redirect_non_admin
      redirect_to root_path, alert: "Accès réservé aux administrateurs."
    end
  end
end
