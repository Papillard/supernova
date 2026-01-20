import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="selection-modal"
// Handles modal with checkboxes for selecting multiple items
export default class extends Controller {
  static targets = ["modal", "button", "checkbox", "hiddenInput", "countDisplay"]
  static values = {
    fieldName: String,
    selected: Array
  }

  connect() {
    this.handleEscape = this.handleEscape.bind(this)
    this.handlePrimarySubjectChange = this.handlePrimarySubjectChange.bind(this)
    document.addEventListener("keydown", this.handleEscape)
    this.element.addEventListener("primary-subject-changed", this.handlePrimarySubjectChange)
    
    // Initialize from existing hidden inputs
    if (this.hasHiddenInputTarget) {
      const container = this.hiddenInputTarget.parentElement
      const existingInputs = Array.from(container.querySelectorAll(`input[name="${this.hiddenInputTarget.name}"]`))
        .filter(input => input.value && input.value !== "")

      const initialValues = existingInputs.map(input => input.value)
      this.selectedValue = initialValues

      // Check checkboxes
      initialValues.forEach(value => {
        const checkbox = this.checkboxTargets.find(cb => cb.value === value)
        if (checkbox) {
          checkbox.checked = true
        }
      })
    }
    this.updateButtonText()
  }

  handlePrimarySubjectChange(event) {
    // Quand la matière principale change, mettre à jour la sélection
    this.updateSelection()
  }

  open(event) {
    event.preventDefault()
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden")
      document.body.style.overflow = "hidden"
    }
  }

  close(event) {
    event?.preventDefault()
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
      document.body.style.overflow = ""
    }
  }

  backdropClick(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  updateSelection() {
    // Always read from checkboxes, even if modal is closed
    const selected = []
    this.checkboxTargets.forEach(checkbox => {
      if (checkbox.checked) {
        selected.push(checkbox.value)
      }
    })
    this.selectedValue = selected
    this.updateHiddenInputs()
    this.updateButtonText()
  }

  updateHiddenInputs() {
    if (!this.hasHiddenInputTarget) return

    // Always find the main teacher profile form first (most reliable method)
    // This works even when panels are hidden
    let form = document.querySelector('form[action*="teacher/profile"]:not(#avatar-upload-form)')

    // If not found, try to find form from the controller element
    if (!form) {
      form = this.element.closest("form")
    }

    // If still not found, try to find form from the hidden input's ancestors
    if (!form) {
      let parent = this.hiddenInputTarget.parentElement
      while (parent && parent !== document.body) {
        if (parent.tagName === 'FORM') {
          form = parent
          break
        }
        parent = parent.parentElement
      }
    }

    if (!form) {
      // Fallback to parent element if no form found
      const container = this.hiddenInputTarget.parentElement
      const existingInputs = Array.from(container.querySelectorAll(`input[name="${this.hiddenInputTarget.name}"]`))
        .filter(input => input !== this.hiddenInputTarget && input.value !== "")

      existingInputs.forEach(input => input.remove())

      this.selectedValue.forEach(value => {
        if (value && value !== "") {
          const input = document.createElement("input")
          input.type = "hidden"
          input.name = this.hiddenInputTarget.name
          input.value = value
          container.appendChild(input)
        }
      })
      return
    }

    // Remove all existing hidden inputs with the same name from the form
    // but keep the initial hidden input (the one with data-selection-modal-target="hiddenInput")
    // We need to preserve it as a marker for the controller
    const existingInputs = Array.from(form.querySelectorAll(`input[name="${this.hiddenInputTarget.name}"]`))
      .filter(input => input !== this.hiddenInputTarget)

    existingInputs.forEach(input => input.remove())

    // Clear the value of the marker input if we have selected values
    // This ensures we don't send an empty string when we have real values
    if (this.selectedValue.length > 0) {
      this.hiddenInputTarget.value = ""
      // Add new hidden inputs to the form (only non-empty values)
      this.selectedValue.forEach(value => {
        if (value && value !== "") {
          const input = document.createElement("input")
          input.type = "hidden"
          input.name = this.hiddenInputTarget.name
          input.value = value
          form.appendChild(input)
        }
      })
    } else {
      // If no values selected, keep the marker input with empty value
      // This ensures the form always has at least one input for this field
      this.hiddenInputTarget.value = ""
    }
  }

  updateButtonText() {
    if (!this.hasButtonTarget) return

    const count = this.selectedValue.length
    const span = this.buttonTarget.querySelector('span:first-child')

    if (count === 0) {
      if (span) {
        span.textContent = "Sélectionner..."
      }
    } else {
      // Get all selected labels
      const selectedLabels = []
      this.selectedValue.forEach(value => {
        const checkbox = this.checkboxTargets.find(cb => cb.value === value)
        if (checkbox && checkbox.dataset.label) {
          selectedLabels.push(checkbox.dataset.label)
        }
      })

      if (selectedLabels.length > 0) {
        let text
        const maxDisplay = 2

        if (selectedLabels.length <= maxDisplay) {
          // Afficher tous les éléments s'il y en a 2 ou moins
          text = selectedLabels.join(", ")
        } else {
          // Afficher les 2 premiers + le nombre d'éléments restants
          const displayed = selectedLabels.slice(0, maxDisplay)
          const remaining = selectedLabels.length - maxDisplay
          text = displayed.join(", ") + ` +${remaining}`
        }

        if (span) {
          span.textContent = text
        }
      } else {
        // Fallback if no labels found
        if (span) {
          span.textContent = count === 1 ? `${count} sélectionné` : `${count} sélectionnés`
        }
      }
    }
  }

  handleEscape(event) {
    if (event.key === "Escape" && this.hasModalTarget && !this.modalTarget.classList.contains("hidden")) {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleEscape)
    this.element.removeEventListener("primary-subject-changed", this.handlePrimarySubjectChange)
  }
}
