class TeachersController < ApplicationController
  layout "authenticated"
  before_action :authenticate_user!

  def index
    # Placeholder page for listing teachers
    # Will be implemented in a future sprint
  end
end
