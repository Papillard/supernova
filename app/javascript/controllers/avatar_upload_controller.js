import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="avatar-upload"
// Handles automatic form submission when file is selected
export default class extends Controller {
  static targets = ["input", "form", "loadingIndicator"]

  connect() {
    // Auto-submit when file is selected
    if (this.hasInputTarget) {
      this.inputTarget.addEventListener("change", this.handleFileChange.bind(this))
    }

    // Auto-submit when checkbox changes (but without loading indicator)
    const checkbox = this.element.querySelector('input[type="checkbox"][name*="picture_visible"]')
    if (checkbox) {
      checkbox.addEventListener("change", this.handleCheckboxChange.bind(this))
    }

    // Hide loading indicator when form submission ends
    if (this.hasFormTarget) {
      this.formTarget.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
    }
  }

  disconnect() {
    // Clean up event listeners if needed
    if (this.hasInputTarget) {
      this.inputTarget.removeEventListener("change", this.handleFileChange)
    }
  }

  handleFileChange() {
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.remove("hidden")
    }
    if (this.hasFormTarget) {
      this.formTarget.requestSubmit()
    }
  }

  handleCheckboxChange() {
    // Submit form for checkbox change, but without loading indicator
    if (this.hasFormTarget) {
      this.formTarget.requestSubmit()
    }
  }

  handleSubmitEnd() {
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.add("hidden")
    }
  }
}
