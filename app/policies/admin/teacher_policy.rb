# frozen_string_literal: true

module Admin
  class TeacherPolicy < ApplicationPolicy
    # index? : admin
    def index?
      admin?
    end

    # show? : admin
    def show?
      admin?
    end

    # approve? : admin
    def approve?
      admin?
    end

    # reject? : admin
    def reject?
      admin?
    end

    # Scope : tous les teachers
    class Scope < ApplicationPolicy::Scope
      def resolve
        if user&.admin?
          scope.all
        else
          scope.none
        end
      end
    end

    private

    def admin?
      user&.admin?
    end
  end
end
