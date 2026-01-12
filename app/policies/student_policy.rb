# frozen_string_literal: true

class StudentPolicy < ApplicationPolicy
  # create? : parent propriétaire
  def create?
    parent_owner?
  end

  # edit? / update? : parent propriétaire
  def edit?
    parent_owner?
  end

  def update?
    parent_owner?
  end

  # destroy? : parent propriétaire
  def destroy?
    parent_owner?
  end

  # Scope : students du parent
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.parent? && user.parent_profile
        scope.where(parent_profile: user.parent_profile)
      else
        scope.none
      end
    end
  end

  private

  def parent_owner?
    return false unless user&.parent? && user.parent_profile

    record.parent_profile == user.parent_profile
  end
end
