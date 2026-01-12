# frozen_string_literal: true

class TeacherPolicy < ApplicationPolicy
  # index? : public
  def index?
    true
  end

  # show? : public si approved + rgpd_consent | propriétaire toujours
  def show?
    owner? || (record.approved? && record.rgpd_consent?)
  end

  # edit? / update? : propriétaire
  def edit?
    owner?
  end

  def update?
    owner?
  end

  # Scope : public → public_visible (approved + rgpd_consent) | teacher → public_visible + self
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.teacher?
        scope.public_visible.or(scope.where(id: user.teacher&.id))
      else
        scope.public_visible
      end
    end
  end

  private

  def owner?
    user&.teacher? && user.teacher == record
  end
end
