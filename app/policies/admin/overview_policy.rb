# frozen_string_literal: true

module Admin
  class OverviewPolicy < ApplicationPolicy
    def index?
      admin?
    end

    private

    def admin?
      user&.admin?
    end
  end
end
