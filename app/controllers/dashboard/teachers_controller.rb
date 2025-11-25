module Dashboard
  class TeachersController < ApplicationController
    layout "authenticated"
    before_action :authenticate_user!
    before_action :ensure_teacher!

    def show
      # Placeholder page for teacher dashboard
      # Will be implemented in a future sprint
    end

    private

    def ensure_teacher!
      redirect_to root_path unless current_user&.teacher?
    end
  end
end
