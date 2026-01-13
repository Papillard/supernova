# frozen_string_literal: true

class TeacherVerificationDocumentPolicy < ApplicationPolicy
  # create? : teacher propriétaire
  def create?
    owner?
  end

  # destroy? : teacher propriétaire
  def destroy?
    owner?
  end

  # show? : teacher propriétaire + admin
  def show?
    owner? || user&.admin?
  end

  # Scope : docs du teacher courant
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.teacher?
        # Active Storage attachments for the current teacher
        scope.where(record_type: "Teacher", record_id: user.teacher&.id)
      else
        scope.none
      end
    end
  end

  private

  def owner?
    return false unless user&.teacher?

    # record can be:
    # - a Teacher model (for create action)
    # - an ActiveStorage::Attachment (for destroy action)
    if record.is_a?(Teacher)
      record == user.teacher
    elsif record.respond_to?(:record)
      # ActiveStorage::Attachment
      record.record == user.teacher
    else
      false
    end
  end
end
