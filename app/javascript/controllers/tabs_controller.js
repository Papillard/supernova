import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
// Handles tab navigation for multi-step forms
export default class extends Controller {
  static targets = ["tab", "panel"]
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
    if (selectedTab) {
      selectedTab.classList.add("tab-active")
    }

    // Update active value
    this.activeValue = tabId
  }

  switch(event) {
    event.preventDefault()
    const tabId = event.currentTarget.dataset.tabId
    if (tabId) {
      this.showTab(tabId)
    }
  }

  next(event) {
    if (event) event.preventDefault()

    // Find the form - the panels are inside the form, so find form from any panel
    let form = null
    if (this.panelTargets.length > 0) {
      form = this.panelTargets[0].closest("form")
    }

    // Fallback: try to find form by selector
    if (!form) {
      form = document.querySelector('form[action*="teacher/profile"]:not(#avatar-upload-form)')
    }

    if (form) {
      // Submit the form and navigate after success
      this.submitAndNavigate(form, () => {
        const currentIndex = this.tabTargets.findIndex(tab => tab.classList.contains("tab-active"))
        if (currentIndex >= 0 && currentIndex < this.tabTargets.length - 1) {
          const nextTab = this.tabTargets[currentIndex + 1]
          if (nextTab && nextTab.dataset.tabId) {
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

    // Store callback for after submission
    this._pendingNavigation = callback

    // Submit form with Turbo
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
