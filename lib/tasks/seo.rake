namespace :seo do
  desc "Generate SEO content for pages using Anthropic API"
  task generate_content: :environment do
    require "net/http"
    require "json"

    api_key = ENV["ANTHROPIC_API_KEY"]
    abort "Set ANTHROPIC_API_KEY env var" unless api_key.present?

    pages = SeoPage.where(page_type: "subject_city").includes(:subject, :city, :seo_contents)
    total = pages.count
    skipped = 0
    generated = 0
    errors = 0

    pages.find_each.with_index do |page, index|
      # Skip if already has non-placeholder intro content (> 300 chars)
      existing_intro = page.content_block("intro")
      if existing_intro.present? && existing_intro.length > 300
        skipped += 1
        next
      end

      subject_name = page.subject&.display_name || "cette matiere"
      city_name = page.city.name

      prompt = <<~PROMPT
        Tu es un redacteur SEO pour ProfConnect, une plateforme de cours particuliers avec des professeurs certifies de l'Education Nationale en France.

        Genere du contenu pour la page "Cours particuliers de #{subject_name} a #{city_name}".

        Reponds en JSON avec ces cles exactes:
        {
          "intro": "Un paragraphe de 3-4 phrases d'introduction (environ 150 mots)",
          "why_us": "Un paragraphe expliquant pourquoi choisir ProfConnect (environ 100 mots)",
          "faq": [
            {"question": "Question 1", "answer": "Reponse 1"},
            {"question": "Question 2", "answer": "Reponse 2"},
            {"question": "Question 3", "answer": "Reponse 3"},
            {"question": "Question 4", "answer": "Reponse 4"}
          ]
        }

        Contraintes:
        - Ecris en francais naturel
        - Mentionne #{city_name} et #{subject_name} naturellement
        - Les FAQ doivent etre utiles pour des parents cherchant des cours pour leur enfant
        - Ne mentionne pas de prix specifiques
        - Insiste sur le fait que les professeurs sont certifies Education Nationale
      PROMPT

      begin
        uri = URI("https://api.anthropic.com/v1/messages")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        request["x-api-key"] = api_key
        request["anthropic-version"] = "2023-06-01"
        request["content-type"] = "application/json"
        request.body = {
          model: "claude-haiku-4-5-20251001",
          max_tokens: 1024,
          messages: [{ role: "user", content: prompt }]
        }.to_json

        response = http.request(request)
        body = JSON.parse(response.body)

        unless response.code == "200"
          raise "API error #{response.code}: #{body.dig('error', 'message') || response.body[0..200]}"
        end

        text = body.dig("content", 0, "text")
        raise "Empty response text" if text.nil?

        # Extract JSON from response (may be wrapped in markdown code block)
        json_match = text.match(/\{[\s\S]*\}/m)
        raise "No JSON found in response" unless json_match

        data = JSON.parse(json_match[0])

        # Update content blocks
        if data["intro"].present?
          page.seo_contents.find_or_initialize_by(block_type: "intro").update!(
            content: data["intro"], position: 0
          )
        end

        if data["why_us"].present?
          page.seo_contents.find_or_initialize_by(block_type: "why_us").update!(
            content: data["why_us"], position: 0
          )
        end

        if data["faq"].is_a?(Array)
          # Remove old FAQ items
          page.seo_contents.where(block_type: "faq").destroy_all

          data["faq"].each_with_index do |faq, i|
            page.seo_contents.create!(
              block_type: "faq",
              position: i,
              content: "#{faq['question']}\n#{faq['answer']}"
            )
          end
        end

        generated += 1
        puts "[#{index + 1}/#{total}] Generated: #{subject_name} - #{city_name}"
      rescue => e
        errors += 1
        puts "[#{index + 1}/#{total}] ERROR: #{subject_name} - #{city_name}: #{e.message}"
      end

      sleep(0.3)
    end

    puts "\nDone! Generated: #{generated}, Skipped: #{skipped}, Errors: #{errors}"
  end
end
