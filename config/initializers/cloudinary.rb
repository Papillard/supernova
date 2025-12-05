if ENV["CLOUDINARY_URL"].present?
  Cloudinary.config_from_url(ENV["CLOUDINARY_URL"])
  Cloudinary.config do |c|
    c.secure = true
  end
end
