import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="format-filter"
export default class extends Controller {
  static targets = ["format", "city"]

  connect() {
    // Attendre un peu pour que le DOM soit complètement chargé
    setTimeout(() => {
      this.updateCityField()
    }, 0)
  }

  formatChanged() {
    this.updateCityField()
    // Le formulaire sera soumis automatiquement par l'action change->form#submit
  }

  updateCityField() {
    if (!this.hasFormatTarget || !this.hasCityTarget) return

    const formatValue = this.formatTarget.value
    const cityContainer = this.cityTarget

    if (formatValue === "online") {
      // Si "En ligne" est sélectionné, reset et griser le champ Ville/Zones
      // Désactiver tous les inputs et boutons dans le conteneur
      const inputs = cityContainer.querySelectorAll('input, button')
      inputs.forEach(input => {
        input.disabled = true
        input.classList.add("opacity-50", "cursor-not-allowed")
      })

      // Réinitialiser les zones sélectionnées si c'est un zone-selector
      const zoneSelector = cityContainer.closest('[data-controller*="zone-selector"]')
      if (zoneSelector) {
        const hiddenInput = zoneSelector.querySelector('[data-zone-selector-target="input"]')
        const searchInput = zoneSelector.querySelector('[data-zone-selector-target="searchInput"]')
        if (hiddenInput) {
          // Vérifier si c'est un single-select (pas de data-zone-selector-single-select-value="false")
          const isSingleSelect = zoneSelector.dataset.zoneSelectorSingleSelectValue !== "false"
          hiddenInput.value = isSingleSelect ? "" : "[]"
        }
        if (searchInput) {
          searchInput.value = ""
        }
        const selectedZonesDiv = zoneSelector.querySelector('[data-zone-selector-target="selectedZones"]')
        if (selectedZonesDiv) {
          selectedZonesDiv.innerHTML = '<p class="text-sm text-gray-500">Aucune zone sélectionnée</p>'
        }
      }
    } else {
      // Sinon, réactiver le champ Ville/Zones
      const inputs = cityContainer.querySelectorAll('input, button')
      inputs.forEach(input => {
        input.disabled = false
        input.classList.remove("opacity-50", "cursor-not-allowed")
      })
    }
  }
}
