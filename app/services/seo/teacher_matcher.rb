module Seo
  class TeacherMatcher
    def initialize(subject: nil, city:)
      @subject = subject
      @city = city
    end

    def call
      scope = Teacher.public_visible

      scope = match_subject(scope) if @subject
      scope = match_city(scope)

      scope.distinct
    end

    private

    def match_subject(scope)
      tag = @subject.tag_code
      scope.where("primary_subject = :tag OR :tag = ANY(subjects_tags)", tag: tag)
    end

    def match_city(scope)
      conditions = []
      binds = {}

      # Match by served_zones overlap
      if @city.served_zone_codes.present?
        conditions << "served_zones && ARRAY[:zone_codes]::text[]"
        binds[:zone_codes] = @city.served_zone_codes
      end

      # Match by city name
      conditions << "LOWER(city) = LOWER(:city_name)"
      binds[:city_name] = @city.name

      # Match by department code prefix on zip_code
      conditions << "zip_code LIKE :dept_prefix"
      binds[:dept_prefix] = "#{@city.department_code}%"

      # For arrondissements, also match parent city
      if @city.parent_city.present?
        conditions << "LOWER(city) = LOWER(:parent_city)"
        binds[:parent_city] = @city.parent_city
      end

      scope.where(conditions.join(" OR "), **binds)
    end
  end
end
