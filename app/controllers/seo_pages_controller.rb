class SeoPagesController < ApplicationController
  layout "application"

  def subject_city
    @subject = Subject.find_by(slug: params[:subject_slug])
    @city = City.find_by(slug: params[:city_slug])

    if @subject.nil? || @city.nil?
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
      return
    end

    @seo_page = SeoPage.published.find_by(subject: @subject, city: @city, page_type: "subject_city")

    if @seo_page.nil?
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
      return
    end

    @teachers = Seo::TeacherMatcher.new(subject: @subject, city: @city).call
    @seo_page.update_column(:teacher_count, @teachers.count)

    @related_cities = City.where(department_code: @city.department_code)
                         .where.not(id: @city.id)
                         .limit(8)

    @other_subjects = Subject.joins(:seo_pages)
                             .where(seo_pages: { city_id: @city.id, published: true })
                             .where.not(id: @subject.id)
                             .distinct
                             .limit(8)
  end

  def city_hub
    @city = City.find_by(slug: params[:city_slug])

    if @city.nil?
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
      return
    end

    @seo_page = SeoPage.published.find_by(city: @city, page_type: "city_hub")

    @subject_pages = SeoPage.published
                            .where(city: @city, page_type: "subject_city")
                            .includes(:subject)
                            .order("subjects.display_name")
                            .references(:subject)
  end
end
