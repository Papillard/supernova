# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  # create? : membre de la request
  def create?
    member_of_request?
  end

  # Scope : messages des requests du scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      request_ids = RequestPolicy::Scope.new(user, Request).resolve.pluck(:id)
      scope.where(request_id: request_ids)
    end
  end

  private

  def member_of_request?
    return false unless user && record.request

    request = record.request
    (user.parent? && request.parent == user) ||
      (user.teacher? && request.teacher == user.teacher)
  end
end
