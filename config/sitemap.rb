SitemapGenerator::Sitemap.default_host = "https://www.prof-connect.fr"

SitemapGenerator::Sitemap.create do
  # Static pages
  add root_path, changefreq: "weekly", priority: 1.0
  add conditions_generales_path, changefreq: "monthly", priority: 0.3
  add politique_de_confidentialite_path, changefreq: "monthly", priority: 0.3
  add mentions_legales_path, changefreq: "monthly", priority: 0.3

  # SEO landing pages
  SeoPage.published.includes(:subject, :city).find_each do |page|
    if page.page_type == "subject_city" && page.subject && page.city
      add seo_subject_city_path(subject_slug: page.subject.slug, city_slug: page.city.slug),
          changefreq: "weekly", priority: 0.8
    elsif page.page_type == "city_hub" && page.city
      add seo_city_hub_path(city_slug: page.city.slug),
          changefreq: "weekly", priority: 0.7
    end
  end
end
