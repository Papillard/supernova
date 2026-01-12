# frozen_string_literal: true

class RequestPolicy < ApplicationPolicy
  # index? : user connecté
  def index?
    user.present?
  end

  # show? : membre de la request (parent propriétaire ou teacher concerné)
  def show?
    member?
  end

  # create? : parent → teacher approved + rgpd_consent
  def create?
    user&.parent? && record.teacher&.approved? && record.teacher&.rgpd_consent?
  end

  # destroy? : parent propriétaire uniquement, et seulement si pending
  def destroy?
    parent_owner? && record.pending?
  end

  # archive? : membre de la request (parent ou teacher)
  def archive?
    member?
  end

  # accept? : teacher concerné
  def accept?
    teacher_owner?
  end

  # decline? : teacher concerné
  def decline?
    teacher_owner?
  end

  # Scope : uniquement mes requests (parent ou teacher)
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.parent?
        scope.where(parent: user)
      elsif user&.teacher?
        scope.where(teacher: user.teacher)
      else
        scope.none
      end
    end
  end

  private

  def member?
    parent_owner? || teacher_owner?
  end

  def parent_owner?
    user&.parent? && record.parent == user
  end

  def teacher_owner?
    user&.teacher? && record.teacher == user.teacher
  end
end
