# frozen_string_literal: true

class ParentProfilePolicy < ApplicationPolicy
  # show? : parent propriétaire
  def show?
    owner?
  end

  # edit? / update? : parent propriétaire
  def edit?
    owner?
  end

  def update?
    owner?
  end

  # Scope : self
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.parent?
        scope.where(user: user)
      else
        scope.none
      end
    end
  end

  private

  def owner?
    user&.parent? && record.user == user
  end
end
