import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="single-selection-modal"
// Handles modal with radio buttons for selecting a single item
export default class extends Controller {
  static targets = ["modal", "button", "radio", "hiddenInput"]
  static values = {
    fieldName: String,
    selected: String
  }

  connect() {
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.handleEscape)
    // Initialize from existing hidden input
    if (this.hasHiddenInputTarget && this.hiddenInputTarget.value) {
      this.selectedValue = this.hiddenInputTarget.value

      // Check radio button
      const radio = this.radioTargets.find(rb => rb.value === this.selectedValue)
      if (radio) {
        radio.checked = true
      }
    }
    this.updateButtonText()
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
    const selectedRadio = this.radioTargets.find(radio => radio.checked)
    if (selectedRadio) {
      const previousValue = this.selectedValue
      this.selectedValue = selectedRadio.value
      this.updateHiddenInput()
      this.updateButtonText()
      
      // Si c'est le champ primary_subject, mettre à jour la modal "Autres matières"
      if (this.fieldNameValue === "primary_subject") {
        this.updateOtherSubjectsModal(previousValue, this.selectedValue)
      }
      
      // Optionally close modal after selection
      // this.close()
    }
  }

  updateOtherSubjectsModal(previousPrimarySubject, newPrimarySubject) {
    // Trouver le contrôleur selection-modal pour subjects_tags
    const otherSubjectsController = document.querySelector('[data-controller*="selection-modal"][data-selection-modal-field-name-value="subjects_tags"]')
    if (!otherSubjectsController) return

    // Trouver toutes les checkboxes dans la modal "Autres matières"
    const otherSubjectsModal = otherSubjectsController.querySelector('[data-selection-modal-target="modal"]')
    if (!otherSubjectsModal) return

    const checkboxes = otherSubjectsModal.querySelectorAll('[data-selection-modal-target="checkbox"]')
    
    checkboxes.forEach(checkbox => {
      const checkboxValue = checkbox.value
      const label = checkbox.closest('label[data-subject-value]')
      
      // Si la nouvelle matière principale correspond à cette checkbox, la masquer/désactiver
      if (checkboxValue === newPrimarySubject) {
        if (label) {
          label.classList.add('hidden')
          checkbox.checked = false
          checkbox.disabled = true
        }
        // Retirer cette matière de subjects_tags si elle y est
        this.removeFromOtherSubjects(checkboxValue)
      }
      
      // Si l'ancienne matière principale correspond à cette checkbox, la réafficher
      if (previousPrimarySubject && checkboxValue === previousPrimarySubject) {
        if (label) {
          label.classList.remove('hidden')
          checkbox.disabled = false
        }
      }
    })

    // Déclencher un événement personnalisé pour mettre à jour le contrôleur selection-modal
    const event = new CustomEvent('primary-subject-changed', {
      detail: { previousValue: previousPrimarySubject, newValue: newPrimarySubject },
      bubbles: true
    })
    otherSubjectsController.dispatchEvent(event)
  }

  removeFromOtherSubjects(subjectValue) {
    // Trouver le formulaire
    let form = document.querySelector('form[action*="teacher/profile"]:not(#avatar-upload-form)')
    if (!form) return

    // Retirer tous les hidden inputs pour cette matière dans subjects_tags
    const subjectInputs = form.querySelectorAll('input[name="teacher[subjects_tags][]"]')
    subjectInputs.forEach(input => {
      if (input.value === subjectValue) {
        input.remove()
      }
    })
  }

  updateHiddenInput() {
    if (!this.hasHiddenInputTarget) return

    // Always find the main teacher profile form first
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

    // Update the hidden input value
    if (this.selectedValue) {
      this.hiddenInputTarget.value = this.selectedValue
    } else {
      this.hiddenInputTarget.value = ""
    }
  }

  updateButtonText() {
    if (!this.hasButtonTarget) return

    const span = this.buttonTarget.querySelector('span:first-child')

    if (!this.selectedValue || this.selectedValue === "") {
      if (span) {
        span.textContent = "Sélectionner votre matière principale"
      }
    } else {
      // Get the selected label
      const selectedRadio = this.radioTargets.find(rb => rb.value === this.selectedValue)
      if (selectedRadio && selectedRadio.dataset.label) {
        if (span) {
          span.textContent = selectedRadio.dataset.label
        }
      } else {
        if (span) {
          span.textContent = "Sélectionné"
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
  }
}
