import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="verification-documents"
// Simple controller: auto-submit on file selection, show loading state
export default class extends Controller {
  static targets = ["input", "preview", "loadingIndicator"]

  connect() {
    // Listen for Turbo form submission end to reset form
    this.element.addEventListener("turbo:submit-end", this.reset.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.reset.bind(this))
  }

  submit() {
    // Show loading indicator
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.remove("hidden")
    }

    // Let Turbo handle the form submission
    this.element.requestSubmit()
  }

  reset() {
    // Clear input
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }
    // Clear preview
    if (this.hasPreviewTarget) {
      this.previewTarget.innerHTML = ""
    }
    // Hide loading
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.add("hidden")
    }
  }
}
