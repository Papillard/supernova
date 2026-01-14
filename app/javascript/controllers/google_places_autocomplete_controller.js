import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="google-places-autocomplete"
// Handles Google Places Autocomplete for city and zip code fields
export default class extends Controller {
  static targets = ["zipCode", "city"]

  connect() {
    // Load Google Places API if not already loaded
    if (typeof google === "undefined" || typeof google.maps === "undefined") {
      this.loadGooglePlacesAPI()
    } else {
      this.initializeAutocomplete()
    }
  }

  loadGooglePlacesAPI() {
    const apiKey = this.getApiKey()
    if (!apiKey) {
      console.warn("Google Places API key not configured. Set GOOGLE_MAPS_API_KEY environment variable.")
      return
    }

    const script = document.createElement("script")
    script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places&callback=initGooglePlacesAutocomplete`
    script.async = true
    script.defer = true

    // Set global callback
    window.initGooglePlacesAutocomplete = () => {
      this.initializeAutocomplete()
    }

    document.head.appendChild(script)
  }

  initializeAutocomplete() {
    // Use city field for autocomplete
    if (!this.hasCityTarget) {
      return
    }

    const autocomplete = new google.maps.places.Autocomplete(this.cityTarget, {
      types: ["(cities)"], // Restrict to cities
      componentRestrictions: { country: "fr" } // Restrict to France
    })

    autocomplete.addListener("place_changed", () => {
      const place = autocomplete.getPlace()
      this.fillCityAndZipCode(place)
    })
  }

  fillCityAndZipCode(place) {
    if (!place.address_components) {
      return
    }

    let postalCode = ""
    let city = ""

    place.address_components.forEach((component) => {
      const types = component.types

      if (types.includes("postal_code")) {
        postalCode = component.long_name
      } else if (types.includes("locality")) {
        city = component.long_name
      } else if (types.includes("administrative_area_level_2") && !city) {
        // Fallback to administrative area if locality is not available
        city = component.long_name
      }
    })

    // Set city (already set by autocomplete, but ensure it's correct)
    if (this.hasCityTarget && city) {
      this.cityTarget.value = city
    }

    // Set zip code
    if (this.hasZipCodeTarget && postalCode) {
      this.zipCodeTarget.value = postalCode
    }
  }

  getApiKey() {
    // Try to get API key from meta tag or data attribute
    const metaTag = document.querySelector('meta[name="google-places-api-key"]')
    if (metaTag) {
      return metaTag.getAttribute("content")
    }

    // Fallback: check if API key is set in a data attribute on the element
    if (this.element.dataset.apiKey) {
      return this.element.dataset.apiKey
    }

    return null
  }
}
