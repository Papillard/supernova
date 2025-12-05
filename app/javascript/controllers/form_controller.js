import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { debounce: Number }

  connect() {
    this.debounceValue = this.debounceValue || 500
  }

  submit() {
    this.element.requestSubmit()
  }

  submitDebounced() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.debounceValue)
  }
}

