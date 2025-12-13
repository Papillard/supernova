import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="google-places-autocomplete"
// Handles Google Places Autocomplete for address fields
export default class extends Controller {
  static targets = ["address", "zipCode", "city"]

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
    if (!this.hasAddressTarget) {
      return
    }

    const autocomplete = new google.maps.places.Autocomplete(this.addressTarget, {
      types: ["address"],
      componentRestrictions: { country: "fr" } // Restrict to France
    })

    autocomplete.addListener("place_changed", () => {
      const place = autocomplete.getPlace()
      this.fillAddressFields(place)
    })
  }

  fillAddressFields(place) {
    if (!place.address_components) {
      return
    }

    let streetNumber = ""
    let route = ""
    let postalCode = ""
    let city = ""

    place.address_components.forEach((component) => {
      const types = component.types

      if (types.includes("street_number")) {
        streetNumber = component.long_name
      } else if (types.includes("route")) {
        route = component.long_name
      } else if (types.includes("postal_code")) {
        postalCode = component.long_name
      } else if (types.includes("locality")) {
        city = component.long_name
      } else if (types.includes("administrative_area_level_2") && !city) {
        // Fallback to administrative area if locality is not available
        city = component.long_name
      }
    })

    // Set address field
    if (this.hasAddressTarget) {
      const fullAddress = [streetNumber, route].filter(Boolean).join(" ")
      this.addressTarget.value = fullAddress || place.formatted_address || ""
    }

    // Set zip code
    if (this.hasZipCodeTarget && postalCode) {
      this.zipCodeTarget.value = postalCode
    }

    // Set city
    if (this.hasCityTarget && city) {
      this.cityTarget.value = city
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
