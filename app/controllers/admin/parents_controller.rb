module Admin
  class ParentsController < ApplicationController
    layout "authenticated"
    before_action :authenticate_user!
    before_action :set_parent, only: [:show]

    rescue_from Pundit::NotAuthorizedError, with: :redirect_non_admin

    def index
      authorize [:admin, ParentProfile]
      @parents = policy_scope([:admin, ParentProfile])
        .includes(:user, :students)
        .order(created_at: :desc)

      case params[:filter]
      when "complete"
        @parents = @parents.completed
      when "incomplete"
        @parents = @parents.incomplete
      end
    end

    def show
      authorize [:admin, @parent]
      @students = @parent.students
      @requests_count = Request.where(parent_id: @parent.user_id).count
    end

    private

    def set_parent
      @parent = ParentProfile.find(params[:id])
    end

    def redirect_non_admin
      redirect_to root_path, alert: "Acces reserve aux administrateurs."
    end
  end
end
