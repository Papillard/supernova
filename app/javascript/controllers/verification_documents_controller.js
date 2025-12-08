import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="verification-documents"
// Handles preview of selected files and auto-submit on file selection
export default class extends Controller {
  static targets = ["input", "form", "preview", "loadingIndicator"]

  connect() {
    if (this.hasInputTarget) {
      this.inputTarget.addEventListener("change", this.handleFileChange.bind(this))
    }
    if (this.hasFormTarget) {
      this.formTarget.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
    }
    this.objectURLs = []
  }

  disconnect() {
    if (this.hasInputTarget) {
      this.inputTarget.removeEventListener("change", this.handleFileChange)
    }
    // Clean up object URLs to prevent memory leaks
    this.cleanupObjectURLs()
  }

  handleFileChange(event) {
    const files = Array.from(event.target.files)
    if (files.length === 0) return

    // Show preview
    this.showPreview(files)

    // Show loading indicator
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.remove("hidden")
    }

    // Auto-submit form
    if (this.hasFormTarget) {
      this.formTarget.requestSubmit()
    }
  }

  showPreview(files) {
    if (!this.hasPreviewTarget) return

    // Clean up previous object URLs
    this.cleanupObjectURLs()

    const previewContainer = this.previewTarget
    previewContainer.innerHTML = ""

    files.forEach((file) => {
      const previewItem = document.createElement("div")
      previewItem.className = "flex items-center gap-2 p-2 bg-gray-50 rounded"

      if (file.type.startsWith("image/")) {
        // Image preview
        const img = document.createElement("img")
        const objectURL = URL.createObjectURL(file)
        this.objectURLs.push(objectURL)
        img.src = objectURL
        img.className = "w-16 h-16 object-cover rounded"
        previewItem.appendChild(img)
      } else if (file.type === "application/pdf") {
        // PDF icon
        const icon = document.createElement("div")
        icon.className = "w-16 h-16 bg-red-100 rounded flex items-center justify-center"
        icon.innerHTML = `
          <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
          </svg>
        `
        previewItem.appendChild(icon)
      }

      // File name
      const fileName = document.createElement("span")
      fileName.className = "text-sm text-gray-700 flex-1"
      fileName.textContent = file.name
      previewItem.appendChild(fileName)

      previewContainer.appendChild(previewItem)
    })
  }

  handleSubmitEnd() {
    // Clear preview and input
    if (this.hasPreviewTarget) {
      this.previewTarget.innerHTML = ""
    }
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.add("hidden")
    }
    // Clean up object URLs
    this.cleanupObjectURLs()
  }

  cleanupObjectURLs() {
    if (this.objectURLs) {
      this.objectURLs.forEach(url => URL.revokeObjectURL(url))
      this.objectURLs = []
    }
  }
}
