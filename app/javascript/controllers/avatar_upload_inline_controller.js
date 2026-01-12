import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="avatar-upload-inline"
// Handles avatar upload via fetch without a separate form
export default class extends Controller {
  connect() {
    this.loadingIndicator = document.getElementById("avatar-upload-loading")
  }

  async upload(event) {
    const file = event.target.files[0]
    if (!file) return

    // Show loading indicator
    if (this.loadingIndicator) {
      this.loadingIndicator.classList.remove("hidden")
    }

    try {
      // Create FormData with the file
      const formData = new FormData()
      formData.append("teacher[avatar]", file)
      formData.append("avatar_only", "1")

      // Get CSRF token
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

      // Send request
      const response = await fetch("/teacher/profile", {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "text/vnd.turbo-stream.html"
        },
        body: formData
      })

      if (response.ok) {
        const html = await response.text()
        // Process Turbo Stream response
        Turbo.renderStreamMessage(html)
      } else {
        console.error("Avatar upload failed:", response.status)
      }
    } catch (error) {
      console.error("Avatar upload error:", error)
    } finally {
      // Hide loading indicator
      if (this.loadingIndicator) {
        this.loadingIndicator.classList.add("hidden")
      }
      // Clear the input
      event.target.value = ""
    }
  }
}
