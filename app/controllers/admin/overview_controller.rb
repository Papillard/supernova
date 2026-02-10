module Admin
  class OverviewController < ApplicationController
    layout "authenticated"
    before_action :authenticate_user!

    rescue_from Pundit::NotAuthorizedError, with: :redirect_non_admin

    def index
      authorize [:admin, :overview]

      # Summary cards
      @total_teachers = Teacher.count
      @total_parents = User.where(role: "parent").count
      @total_requests = Request.count
      @teachers_with_requests_pct = calculate_teachers_with_requests_percentage

      # Monthly stats (last 12 months)
      @months = last_12_months
      @teachers_by_month = cumulative_counts(Teacher, @months)
      @parents_by_month = cumulative_counts(User.where(role: "parent"), @months)
      @requests_by_month = monthly_counts(Request, @months)
    end

    private

    def last_12_months
      12.downto(0).map { |i| i.months.ago.beginning_of_month.to_date }
    end

    def cumulative_counts(scope, months)
      counts = scope.group("DATE_TRUNC('month', created_at)").count
      cumulative = 0
      months.map do |month|
        month_key = month.beginning_of_month.to_time
        cumulative += counts[month_key] || 0
        [month, cumulative]
      end.to_h
    end

    def monthly_counts(scope, months)
      counts = scope.group("DATE_TRUNC('month', created_at)").count
      months.map do |month|
        month_key = month.beginning_of_month.to_time
        [month, counts[month_key] || 0]
      end.to_h
    end

    def calculate_teachers_with_requests_percentage
      total = Teacher.count
      return 0 if total.zero?

      with_requests = Teacher.joins(:requests).distinct.count
      (with_requests.to_f / total * 100).round(1)
    end

    def redirect_non_admin
      redirect_to root_path, alert: "Acces reserve aux administrateurs."
    end
  end
end
