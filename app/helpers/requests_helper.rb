module RequestsHelper
  # Options pour les niveaux (conforme au spec: primaire / college / lycee / prepa / bts / sup)
  LEVELS_OPTIONS = [
    ["Primaire", "primaire"],
    ["Collège", "college"],
    ["Lycée", "lycee"],
    ["Prépa", "prepa"],
    ["BTS", "bts"],
    ["Supérieur", "sup"]
  ].freeze

  def format_request_status(status)
    case status
    when "pending"
      "En attente"
    when "accepted"
      "Acceptée"
    when "declined"
      "Refusée"
    else
      status.humanize
    end
  end

  def request_status_badge_class(status)
    case status
    when "pending"
      "badge-warning"
    when "accepted"
      "badge-success"
    when "declined"
      "badge-error"
    else
      "badge"
    end
  end

  def format_request_level(level)
    level_option = LEVELS_OPTIONS.find { |_, value| value == level }
    level_option ? level_option[0] : level.humanize
  end
end
