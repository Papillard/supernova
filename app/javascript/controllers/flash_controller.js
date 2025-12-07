import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
// Auto-hides flash messages after a delay
export default class extends Controller {
  static values = {
    autoHide: Boolean,
    delay: Number
  }

  connect() {
    // Auto-hide flash message after delay (default 3 seconds)
    if (this.autoHideValue) {
      const delay = this.hasDelayValue ? this.delayValue : 3000
      this.timeout = setTimeout(() => {
        this.hide()
      }, delay)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  hide() {
    this.element.style.transition = "opacity 0.5s"
    this.element.style.opacity = "0"
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
