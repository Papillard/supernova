module ApplicationHelper
  # Affiche le temps écoulé en français : "il y a 2 heures"
  def time_ago_in_french(time)
    return "" if time.blank?

    "il y a #{time_ago_in_words(time)}"
  end
end
