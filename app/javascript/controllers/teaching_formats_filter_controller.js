import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="teaching-formats-filter"
// Grises the zones section if only "online" format is selected
export default class extends Controller {
  static targets = ["formatCheckbox"]
  static values = { zonesSectionId: String }

  connect() {
    this.updateZonesSection()
  }

  updateZonesSection() {
    const zonesSectionId = this.zonesSectionIdValue || "zones-desservies-section"
    const zonesSection = document.getElementById(zonesSectionId)
    if (!zonesSection) return

    // Check if at least one of "at_student_home" or "at_teacher_home" is checked
    const hasStudentHome = this.isFormatChecked("at_student_home")
    const hasTeacherHome = this.isFormatChecked("at_teacher_home")
    const hasPhysicalFormat = hasStudentHome || hasTeacherHome

    if (hasPhysicalFormat) {
      // Enable zones section
      zonesSection.classList.remove("opacity-50", "pointer-events-none")
      const inputs = zonesSection.querySelectorAll('input, button')
      inputs.forEach(input => {
        input.disabled = false
        input.classList.remove("opacity-50", "cursor-not-allowed")
      })
    } else {
      // Disable and gray out zones section
      zonesSection.classList.add("opacity-50", "pointer-events-none")
      const inputs = zonesSection.querySelectorAll('input, button')
      inputs.forEach(input => {
        input.disabled = true
        input.classList.add("opacity-50", "cursor-not-allowed")
      })

      // Clear selected zones
      const hiddenInput = zonesSection.querySelector('[data-zone-selector-target="input"]')
      if (hiddenInput) {
        hiddenInput.value = "[]"
      }
      const selectedZonesDiv = zonesSection.querySelector('[data-zone-selector-target="selectedZones"]')
      if (selectedZonesDiv) {
        selectedZonesDiv.innerHTML = '<p class="text-sm text-gray-500">Aucune zone sélectionnée</p>'
      }
    }
  }

  isFormatChecked(formatValue) {
    const checkbox = this.formatCheckboxTargets.find(cb => cb.value === formatValue)
    return checkbox ? checkbox.checked : false
  }
}
