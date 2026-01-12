import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
// Handles simple modal open/close functionality
export default class extends Controller {
  static targets = ["modal", "closeButton"]

  open(event) {
    event.preventDefault()
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden")
      // Prevent body scroll when modal is open
      document.body.style.overflow = "hidden"
    }
  }

  close(event) {
    event?.preventDefault()
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
      // Restore body scroll
      document.body.style.overflow = ""
    }
  }

  // Close on backdrop click
  backdropClick(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  // Close on Escape key
  connect() {
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.handleEscape)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleEscape)
  }

  handleEscape(event) {
    if (event.key === "Escape" && this.hasModalTarget && !this.modalTarget.classList.contains("hidden")) {
      this.close()
    }
  }
}
