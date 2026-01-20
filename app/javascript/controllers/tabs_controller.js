import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
// Handles tab navigation for multi-step forms
export default class extends Controller {
  static targets = ["tab", "panel", "currentStep"]
  static values = { active: String }


  showTab(tabId) {
    if (!tabId) return

    // Hide all panels
    this.panelTargets.forEach(panel => {
      panel.classList.add("hidden")
    })

    // Remove active class from all tabs
    this.tabTargets.forEach(tab => {
      tab.classList.remove("tab-active")
    })

    // Show selected panel
    const selectedPanel = this.panelTargets.find(panel => panel.dataset.panelId === tabId)
    if (selectedPanel) {
      selectedPanel.classList.remove("hidden")
    }

    // Add active class to selected tab
    const selectedTab = this.tabTargets.find(tab => tab.dataset.tabId === tabId)
    const currentIndex = this.tabTargets.findIndex(tab => tab.dataset.tabId === tabId)
    if (selectedTab) {
      selectedTab.classList.add("tab-active")
    }

    // Update mobile step indicator
    if (this.hasCurrentStepTarget && currentIndex >= 0) {
      this.currentStepTarget.textContent = currentIndex + 1
    }

    // Update active value
    this.activeValue = tabId

    // Update required attributes based on current step
    this.updateRequiredFields(tabId)
  }

  updateRequiredFields(activeStepId) {
    // Find the form
    let form = null
    if (this.panelTargets.length > 0) {
      form = this.panelTargets[0].closest("form")
    }
    if (!form) {
      form = document.querySelector('form[action*="teacher/profile"]:not(#avatar-upload-form)')
    }
    if (!form) return

    // Update required attributes: add required to fields in active step, remove from others
    // Handle both visible inputs and hidden inputs with data-required-for-step
    const allFields = form.querySelectorAll('[data-required-for-step]')
    allFields.forEach(field => {
      const requiredStep = field.dataset.requiredForStep
      if (requiredStep === activeStepId) {
        // For hidden inputs, we can't use HTML5 required, but we'll validate in JavaScript
        if (field.type !== 'hidden') {
          field.setAttribute('required', 'required')
        }
      } else {
        if (field.type !== 'hidden') {
          field.removeAttribute('required')
        }
      }
    })
  }

  switch(event) {
    event.preventDefault()
    const tabId = event.currentTarget.dataset.tabId
    if (tabId) {
      this.showTab(tabId)
    }
  }

  next(event) {
    console.log("TabsController#next called", event)
    if (event) event.preventDefault()

    // Find the form - the panels are inside the form, so find form from any panel
    let form = null
    if (this.panelTargets.length > 0) {
      form = this.panelTargets[0].closest("form")
      console.log("Form found via panelTargets:", form)
    }

    // Fallback: try to find form by selector
    if (!form) {
      form = document.querySelector('form[action*="teacher/profile"]:not(#avatar-upload-form)')
      console.log("Form found via selector:", form)
    }

    if (form) {
      // Force update all selection-modal controllers before submission
      // This ensures hidden inputs are up-to-date even if user didn't close the modal
      const selectionModals = form.querySelectorAll('[data-controller*="selection-modal"]')
      selectionModals.forEach(element => {
        // Find all controllers connected to this element
        const controllers = this.application.controllers
        const controller = Array.from(controllers).find(c => 
          c.identifier === 'selection-modal' && c.element === element
        )
        if (controller && typeof controller.updateSelection === 'function') {
          controller.updateSelection()
        }
      })

      // Force update all zone-selector controllers before submission
      const zoneSelectors = form.querySelectorAll('[data-controller*="zone-selector"]')
      zoneSelectors.forEach(element => {
        const controllers = this.application.controllers
        const controller = Array.from(controllers).find(c => 
          c.identifier === 'zone-selector' && c.element === element
        )
        if (controller && typeof controller.updateHiddenInput === 'function') {
          controller.updateHiddenInput()
        }
      })

      // Temporarily remove required from fields in hidden panels to allow submission
      const currentPanel = this.panelTargets.find(panel => !panel.classList.contains("hidden"))
      const currentPanelId = currentPanel?.dataset.panelId
      
      // Remove required from all fields not in current panel
      const allRequiredFields = form.querySelectorAll('[required], [data-required-for-step]')
      const fieldsToDisable = []
      
      allRequiredFields.forEach(field => {
        const requiredStep = field.dataset.requiredForStep
        if (requiredStep && requiredStep !== currentPanelId) {
          // Field is required for a different step, temporarily disable required
          if (field.hasAttribute('required')) {
            field.removeAttribute('required')
            fieldsToDisable.push(field)
          }
        }
      })

      console.log("Submitting form and navigating...")
      // Submit the form and navigate after success
      this.submitAndNavigate(form, () => {
        // Re-enable required attributes after navigation
        fieldsToDisable.forEach(field => {
          field.setAttribute('required', 'required')
        })
        
        const currentIndex = this.tabTargets.findIndex(tab => tab.classList.contains("tab-active"))
        console.log("Current tab index:", currentIndex)
        if (currentIndex >= 0 && currentIndex < this.tabTargets.length - 1) {
          const nextTab = this.tabTargets[currentIndex + 1]
          if (nextTab && nextTab.dataset.tabId) {
            console.log("Switching to next tab:", nextTab.dataset.tabId)
            this.showTab(nextTab.dataset.tabId)
          }
        }
      })
    } else {
      // No form found, just navigate
      console.warn("Form not found, navigating without saving")
      const currentIndex = this.tabTargets.findIndex(tab => tab.classList.contains("tab-active"))
      if (currentIndex >= 0 && currentIndex < this.tabTargets.length - 1) {
        const nextTab = this.tabTargets[currentIndex + 1]
        if (nextTab && nextTab.dataset.tabId) {
          this.showTab(nextTab.dataset.tabId)
        }
      }
    }
  }

  submitAndNavigate(form, callback) {
    console.log("submitAndNavigate called", form)
    // Add a hidden field to indicate we should stay on the page
    let stayOnPageInput = form.querySelector('input[name="stay_on_page"]')
    if (!stayOnPageInput) {
      stayOnPageInput = document.createElement("input")
      stayOnPageInput.type = "hidden"
      stayOnPageInput.name = "stay_on_page"
      form.appendChild(stayOnPageInput)
    }
    stayOnPageInput.value = "true"

    // Add current tab to form data
    let currentTabInput = form.querySelector('input[name="current_tab"]')
    if (!currentTabInput) {
      currentTabInput = document.createElement("input")
      currentTabInput.type = "hidden"
      currentTabInput.name = "current_tab"
      form.appendChild(currentTabInput)
    }
    currentTabInput.value = this.activeValue
    console.log("Active value:", this.activeValue)

    // Store callback for after submission
    this._pendingNavigation = callback

    // Submit form with Turbo
    console.log("Submitting form...")
    form.requestSubmit()
  }

  connect() {
    // Set initial active tab from value or default to first tab
    const activeTab = this.activeValue || (this.tabTargets[0]?.dataset.tabId)
    if (activeTab) {
      this.showTab(activeTab)
    } else if (this.tabTargets.length > 0) {
      // Fallback: activate first tab if no active value is set
      this.showTab(this.tabTargets[0].dataset.tabId)
    }

    // Listen for successful form submissions
    // Find form from panels (they are inside the form)
    let form = null
    if (this.panelTargets.length > 0) {
      form = this.panelTargets[0].closest("form")
    }

    // Fallback: try to find form by selector
    if (!form) {
      form = document.querySelector('form[action*="teacher/profile"]:not(#avatar-upload-form)')
    }

    if (form) {
      form.addEventListener("turbo:submit-end", (event) => {
        if (event.detail.success && this._pendingNavigation) {
          // Small delay to ensure DOM is updated
          setTimeout(() => {
            this._pendingNavigation()
            this._pendingNavigation = null
          }, 100)
        } else if (!event.detail.success && this._pendingNavigation) {
          // En cas d'erreur, annuler la navigation en attente
          this._pendingNavigation = null
        }
      })
    }
  }

  previous(event) {
    if (event) event.preventDefault()
    const currentIndex = this.tabTargets.findIndex(tab => tab.classList.contains("tab-active"))
    if (currentIndex > 0) {
      const previousTab = this.tabTargets[currentIndex - 1]
      if (previousTab && previousTab.dataset.tabId) {
        this.showTab(previousTab.dataset.tabId)
      }
    }
  }
}
