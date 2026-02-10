module Admin
  class ParentsController < ApplicationController
    layout "authenticated"
    before_action :authenticate_user!
    before_action :set_parent, only: [:show, :destroy]

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

      parent_user_ids = @parents.map(&:user_id)
      @requests_counts = Request.where(parent_id: parent_user_ids).group(:parent_id).count
    end

    def show
      authorize [:admin, @parent]
      @students = @parent.students
      @requests_count = Request.where(parent_id: @parent.user_id).count
    end

    def destroy
      authorize [:admin, @parent]
      display_name = "#{@parent.first_name} #{@parent.last_name}".strip.presence || "Parent"
      user = @parent.user
      user.destroy!
      redirect_to admin_parents_path, notice: "Le parent #{display_name} et son compte utilisateur ont été supprimés."
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
