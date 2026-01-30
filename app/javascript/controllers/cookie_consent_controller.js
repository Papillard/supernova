import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!localStorage.getItem("cookie_consent")) {
      this.element.classList.remove("hidden")
    }
  }

  accept() {
    localStorage.setItem("cookie_consent", "accepted")
    this.element.classList.add("hidden")
  }
}
