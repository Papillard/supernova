# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # update? : self
  def update?
    user == record
  end

  def edit?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(id: user&.id)
    end
  end
end
