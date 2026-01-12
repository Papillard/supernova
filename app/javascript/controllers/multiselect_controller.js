import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multiselect"
// Handles multi-select dropdown functionality
export default class extends Controller {
  static targets = ["button", "dropdown", "option", "hiddenInput"]
  static values = {
    selected: Array,
    placeholder: String
  }

  connect() {
    // Initialize selected options from data attribute or existing hidden inputs
    let initialValues = []

    // First, try to get from data attribute (JSON)
    if (this.selectedValue.length > 0) {
      initialValues = this.selectedValue
    } else if (this.hasHiddenInputTarget) {
      // Fallback: get from existing hidden inputs
      const container = this.hiddenInputTarget.parentElement
      const existingInputs = Array.from(container.querySelectorAll(`input[name="${this.hiddenInputTarget.name}"]`))
        .filter(input => input.value && input.value !== "")

      initialValues = existingInputs.map(input => input.value)
      this.selectedValue = initialValues
    }

    // Mark options as selected visually
    initialValues.forEach(value => {
      const option = this.optionTargets.find(opt => opt.dataset.value === value)
      if (option) {
        option.classList.add("bg-primary", "text-primary-content")
      }
    })

    this.updateButtonText()
    // Close dropdown when clicking outside
    document.addEventListener("click", this.handleOutsideClick.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick.bind(this))
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle("hidden")
    }
  }

  selectOption(event) {
    event.preventDefault()
    event.stopPropagation()
    const option = event.currentTarget
    const value = option.dataset.value
    const isSelected = option.classList.contains("bg-primary", "text-primary-content")

    if (isSelected) {
      // Deselect
      option.classList.remove("bg-primary", "text-primary-content")
      this.selectedValue = this.selectedValue.filter(v => v !== value)
    } else {
      // Select
      option.classList.add("bg-primary", "text-primary-content")
      this.selectedValue = [...this.selectedValue, value]
    }

    this.updateHiddenInputs()
    this.updateButtonText()
  }

  updateButtonText() {
    if (!this.hasButtonTarget) return

    const count = this.selectedValue.length
    const span = this.buttonTarget.querySelector('span:first-child')

    if (count === 0) {
      if (span) {
        span.textContent = this.placeholderValue || "Sélectionner..."
      }
    } else if (count === 1) {
      const selectedOption = this.optionTargets.find(opt => opt.dataset.value === this.selectedValue[0])
      const text = selectedOption ? selectedOption.textContent.trim() : `${count} sélectionné`
      if (span) {
        span.textContent = text
      }
    } else {
      if (span) {
        span.textContent = `${count} sélectionnés`
      }
    }
  }

  updateHiddenInputs() {
    if (!this.hasHiddenInputTarget) return

    // Remove all existing hidden inputs (except the empty one used as template)
    const container = this.hiddenInputTarget.parentElement
    const existingInputs = Array.from(container.querySelectorAll(`input[name="${this.hiddenInputTarget.name}"]`))
      .filter(input => input !== this.hiddenInputTarget && input.value !== "")

    existingInputs.forEach(input => input.remove())

    // Add hidden inputs for each selected value
    this.selectedValue.forEach(value => {
      if (value && value !== "") {
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = this.hiddenInputTarget.name
        input.value = value
        container.appendChild(input)
      }
    })
  }

  handleOutsideClick(event) {
    if (this.hasDropdownTarget && !this.element.contains(event.target)) {
      this.dropdownTarget.classList.add("hidden")
    }
  }
}
