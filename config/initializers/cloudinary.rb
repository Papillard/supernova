if ENV["CLOUDINARY_URL"].present?
  begin
    Cloudinary.config_from_url(ENV["CLOUDINARY_URL"])
    Cloudinary.config do |c|
      c.secure = true
    end
  rescue => e
    Rails.logger.error "Erreur lors de la configuration Cloudinary: #{e.message}"
  end
end
