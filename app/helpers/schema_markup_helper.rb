module SchemaMarkupHelper
  def faq_schema_json_ld(faq_items)
    return nil if faq_items.blank?

    {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => faq_items.map do |item|
        {
          "@type" => "Question",
          "name" => item[:question],
          "acceptedAnswer" => {
            "@type" => "Answer",
            "text" => item[:answer]
          }
        }
      end
    }.to_json
  end

  def organization_schema_json_ld
    {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => "ProfConnect",
      "url" => "https://www.prof-connect.fr",
      "description" => "ProfConnect met en relation parents et professeurs de l'Education Nationale pour des cours particuliers."
    }.to_json
  end
end
