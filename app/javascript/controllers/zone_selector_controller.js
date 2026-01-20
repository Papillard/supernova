import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="zone-selector"
export default class extends Controller {
  static targets = ["input", "dropdown", "selectedZones", "searchInput"]
  static values = {
    initialZones: Array,
    allZones: Array,
    selected: Array,
    singleSelect: Boolean
  }

  connect() {
    // Initialiser depuis selectedValue (data attribute) - priorité à l'URL
    let initialZones = this.selectedValue || []
    
    // Si selectedValue est vide (pas de paramètre dans l'URL), ne pas utiliser le hidden input
    // car il pourrait contenir une ancienne valeur
    if (initialZones.length === 0) {
      // Pas de paramètre dans l'URL, donc pas de sélection
      initialZones = []
    } else {
      // Il y a un paramètre dans l'URL, utiliser cette valeur
      // Mettre à jour le hidden input pour être cohérent
      if (this.hasInputTarget) {
        if (this.singleSelectValue) {
          this.inputTarget.value = initialZones[0] || ""
        } else {
          this.inputTarget.value = JSON.stringify(initialZones)
        }
      }
    }
    
    // S'assurer que le hidden input a bien son name
    if (this.hasInputTarget && !this.inputTarget.name) {
      this.inputTarget.name = "zones"
    }
    
    this.selectedZonesValue = initialZones
    this.highlightedIndex = -1
    this.renderSelectedZones()
    this.renderDropdown()
    
    // S'assurer que la dropdown est fermée au démarrage
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add("hidden")
    }
    
    // En mode single-select, afficher la zone sélectionnée dans le champ
    if (this.singleSelectValue && this.selectedZonesValue.length > 0) {
      this.updateSearchInputDisplay()
    } else if (this.singleSelectValue) {
      // S'assurer que le champ de recherche est vide si pas de sélection
      this.updateSearchInputDisplay()
    }

    // Écouter les clics à l'extérieur pour fermer la dropdown
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
    
    // Écouter la soumission du formulaire pour gérer le paramètre vide
    const form = this.element.closest("form")
    if (form) {
      this.handleFormSubmit = this.handleFormSubmit.bind(this)
      form.addEventListener("submit", this.handleFormSubmit)
    }
  }

  toggleDropdown() {
    if (this.hasDropdownTarget) {
      const isHidden = this.dropdownTarget.classList.contains("hidden")
      if (isHidden) {
        // Ouvrir la dropdown
        this.openDropdown()
      } else {
        // Fermer la dropdown
        this.closeDropdown()
      }
    }
  }

  openDropdown() {
    if (this.hasDropdownTarget) {
      // S'assurer que la dropdown est bien initialisée avant de l'ouvrir
      const currentQuery = this.hasSearchInputTarget ? this.searchInputTarget.value.trim() : ""
      this.renderDropdown(currentQuery.toLowerCase())
      this.dropdownTarget.classList.remove("hidden")
      this.highlightedIndex = -1
    }
  }

  closeDropdown() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add("hidden")
      this.highlightedIndex = -1
    }
  }

  search(event) {
    const query = event.target.value.trim()
    
    // En mode single-select, si l'utilisateur vide le champ, réinitialiser la sélection
    if (this.singleSelectValue) {
      if (query === "") {
        // Champ vidé : réinitialiser la sélection
        this.selectedZonesValue = []
        this.updateHiddenInput()
        this.updateSearchInputDisplay() // Réinitialiser l'affichage du champ
        // Soumettre le formulaire pour enlever le filtre (avec un petit délai pour éviter les soumissions multiples)
        const form = this.element.closest("form")
        if (form && form.dataset.controller && form.dataset.controller.includes("form")) {
          clearTimeout(this.submitTimeout)
          this.submitTimeout = setTimeout(() => {
            form.requestSubmit()
          }, 300)
        }
      } else {
        // Si l'utilisateur tape quelque chose de différent, réinitialiser la sélection
        const selectedZone = this.selectedZonesValue.length > 0 ? this.findZoneByValue(this.selectedZonesValue[0]) : null
        if (selectedZone && !selectedZone.label.toLowerCase().includes(query.toLowerCase())) {
          // L'utilisateur modifie le texte, réinitialiser la sélection
          this.selectedZonesValue = []
          this.updateHiddenInput()
        }
      }
    }
    
    this.highlightedIndex = -1
    this.renderDropdown(query.toLowerCase())
  }

  handleKeydown(event) {
    // Gérer "Entrée" quand le champ est vide (mode single-select uniquement)
    if (event.key === "Enter" && this.singleSelectValue && this.hasSearchInputTarget) {
      const query = this.searchInputTarget.value.trim()
      if (query === "") {
        // Champ vide : réinitialiser la sélection et soumettre le formulaire
        event.preventDefault()
        this.selectedZonesValue = []
        this.updateHiddenInput()
        this.updateSearchInputDisplay()
        this.closeDropdown()
        
        // Soumettre le formulaire (handleFormSubmit s'occupera de retirer le paramètre)
        const form = this.element.closest("form")
        if (form && form.dataset.controller && form.dataset.controller.includes("form")) {
          form.requestSubmit()
        }
        
        // Réinitialiser la dropdown pour qu'elle puisse s'ouvrir au prochain focus
        setTimeout(() => {
          if (this.hasDropdownTarget) {
            // S'assurer que la dropdown est bien fermée et prête à s'ouvrir
            this.dropdownTarget.classList.add("hidden")
            this.renderDropdown("")
          }
        }, 200)
        
        return
      }
    }

    // Ouvrir le dropdown si fermé et qu'on utilise les flèches
    if ((event.key === "ArrowDown" || event.key === "ArrowUp") && this.hasDropdownTarget && this.dropdownTarget.classList.contains("hidden")) {
      event.preventDefault()
      this.renderDropdown(this.searchInputTarget?.value || "")
      this.dropdownTarget.classList.remove("hidden")
    }

    if (!this.hasDropdownTarget || this.dropdownTarget.classList.contains("hidden")) {
      return
    }

    const buttons = this.dropdownTarget.querySelectorAll('button[data-action*="selectZone"]')
    if (buttons.length === 0) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.highlightedIndex = (this.highlightedIndex + 1) % buttons.length
        this.highlightButton(buttons)
        this.scrollToHighlighted(buttons[this.highlightedIndex])
        break
      case "ArrowUp":
        event.preventDefault()
        this.highlightedIndex = this.highlightedIndex <= 0 ? buttons.length - 1 : this.highlightedIndex - 1
        this.highlightButton(buttons)
        this.scrollToHighlighted(buttons[this.highlightedIndex])
        break
      case "Enter":
        event.preventDefault()
        if (this.highlightedIndex >= 0 && buttons[this.highlightedIndex]) {
          buttons[this.highlightedIndex].click()
        } else if (buttons.length > 0) {
          // Si aucune option n'est highlightée, sélectionner la première
          buttons[0].click()
        }
        break
      case "Escape":
        event.preventDefault()
        this.closeDropdown()
        this.searchInputTarget.blur()
        break
    }
  }

  highlightButton(buttons) {
    buttons.forEach((btn, index) => {
      if (index === this.highlightedIndex) {
        btn.classList.add("bg-gray-100")
        btn.classList.remove("hover:bg-gray-50")
      } else {
        btn.classList.remove("bg-gray-100")
        btn.classList.add("hover:bg-gray-50")
      }
    })
  }

  scrollToHighlighted(element) {
    if (!element) return
    element.scrollIntoView({ block: "nearest", behavior: "smooth" })
  }

  selectZone(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.value

    if (this.singleSelectValue) {
      // Mode single-select : remplacer la sélection
      this.selectedZonesValue = [value]
      this.updateHiddenInput()
      this.updateSearchInputDisplay()
      
      // Soumettre automatiquement le formulaire si on est dans un formulaire de recherche
      const form = this.element.closest("form")
      if (form && form.dataset.controller && form.dataset.controller.includes("form")) {
        // Utiliser Turbo pour soumettre le formulaire
        form.requestSubmit()
      }
    } else {
      // Mode multi-select : ajouter si pas déjà présent
      if (!this.selectedZonesValue.includes(value)) {
        this.selectedZonesValue.push(value)
        this.updateHiddenInput()
        this.renderSelectedZones()
      }
    }

    // Fermer le dropdown et retirer le focus
    this.closeDropdown()
    this.searchInputTarget.blur()
  }

  updateSearchInputDisplay() {
    if (!this.singleSelectValue || !this.hasSearchInputTarget) return

    if (this.selectedZonesValue.length > 0) {
      const zone = this.findZoneByValue(this.selectedZonesValue[0])
      if (zone) {
        this.searchInputTarget.value = zone.label
      } else {
        this.searchInputTarget.value = ""
      }
    } else {
      // Réinitialiser le champ pour afficher le placeholder
      this.searchInputTarget.value = ""
    }
  }

  removeZone(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.value
    this.selectedZonesValue = this.selectedZonesValue.filter(v => v !== value)
    this.updateHiddenInput()
    this.renderSelectedZones()
    if (this.singleSelectValue) {
      this.updateSearchInputDisplay()
    }
  }

  updateHiddenInput() {
    if (this.hasInputTarget) {
      if (this.singleSelectValue) {
        // En mode single-select, stocker juste la valeur unique (pas un array)
        this.inputTarget.value = this.selectedZonesValue.length > 0 ? this.selectedZonesValue[0] : ""
      } else {
        this.inputTarget.value = JSON.stringify(this.selectedZonesValue)
      }
    }
  }

  renderSelectedZones() {
    // En mode single-select, ne pas afficher les badges
    if (this.singleSelectValue) return

    if (!this.hasSelectedZonesTarget) return

    const selectedItems = this.selectedZonesValue.map(value => {
      const zone = this.findZoneByValue(value)
      return zone
    }).filter(Boolean)

    if (selectedItems.length === 0) {
      this.selectedZonesTarget.innerHTML = '<p class="text-sm text-gray-500">Aucune zone sélectionnée</p>'
      return
    }

    this.selectedZonesTarget.innerHTML = selectedItems.map(zone => `
      <span class="inline-flex items-center gap-1 px-2 py-1 bg-[#fe6618]/10 text-[#fe6618] rounded text-sm">
        ${zone.label}
        <button type="button" data-action="click->zone-selector#removeZone" data-value="${zone.value}" class="hover:text-[#d85514]">
          ×
        </button>
      </span>
    `).join("")
  }

  renderDropdown(query = "") {
    if (!this.hasDropdownTarget) return

    let zonesToShow = []

    if (query === "") {
      // Afficher uniquement les zones initiales (Île-de-France + Grandes villes)
      zonesToShow = this.initialZonesValue || []
    } else {
      // Filtrer toutes les zones selon la recherche
      zonesToShow = (this.allZonesValue || []).filter(zone => {
        const searchable = zone.searchable?.toLowerCase() || zone.label.toLowerCase()
        return searchable.includes(query.toLowerCase())
      })
    }

    // Grouper par section
    const grouped = {}
    zonesToShow.forEach(zone => {
      if (!grouped[zone.group]) {
        grouped[zone.group] = []
      }
      if (!this.selectedZonesValue.includes(zone.value)) {
        grouped[zone.group].push(zone)
      }
    })

    if (Object.keys(grouped).length === 0) {
      this.dropdownTarget.innerHTML = '<p class="text-sm text-gray-500 p-4">Aucun résultat</p>'
      this.highlightedIndex = -1
      return
    }

    let html = ""
    let buttonIndex = 0
    Object.entries(grouped).forEach(([groupName, zones]) => {
      if (zones.length > 0) {
        html += `<div class="px-4 py-2 text-xs font-semibold text-gray-500 uppercase">${groupName}</div>`
        zones.forEach(zone => {
          const isHighlighted = buttonIndex === this.highlightedIndex
          html += `
            <button type="button"
                    data-action="click->zone-selector#selectZone"
                    data-value="${zone.value}"
                    class="w-full text-left px-4 py-2 text-sm ${isHighlighted ? 'bg-gray-100' : 'hover:bg-gray-50'}">
              ${zone.label}
            </button>
          `
          buttonIndex++
        })
      }
    })

    this.dropdownTarget.innerHTML = html
  }

  findZoneByValue(value) {
    const allZones = [...(this.initialZonesValue || []), ...(this.allZonesValue || [])]
    return allZones.find(z => z.value === value)
  }

  handleOutsideClick(event) {
    // Fermer la dropdown si on clique en dehors du contrôleur
    if (this.hasDropdownTarget && !this.dropdownTarget.classList.contains("hidden")) {
      const clickedInside = this.element.contains(event.target) || 
                           this.dropdownTarget.contains(event.target) ||
                           (this.hasSearchInputTarget && this.searchInputTarget.contains(event.target))
      
      if (!clickedInside) {
        this.closeDropdown()
        if (this.hasSearchInputTarget) {
          this.searchInputTarget.blur()
        }
      }
    }
  }

  handleFormSubmit(event) {
    // Si le champ est vide, supprimer le paramètre de l'URL en retirant le name
    if (this.singleSelectValue && this.selectedZonesValue.length === 0 && this.hasInputTarget) {
      this.inputTarget.removeAttribute("name")
      // Le remettre après la soumission pour que le contrôleur fonctionne correctement
      setTimeout(() => {
        if (this.hasInputTarget) {
          this.inputTarget.name = "zones"
        }
      }, 100)
    }
  }

  disconnect() {
    if (this.handleOutsideClick) {
      document.removeEventListener("click", this.handleOutsideClick)
    }
    const form = this.element.closest("form")
    if (form && this.handleFormSubmit) {
      form.removeEventListener("submit", this.handleFormSubmit)
    }
  }
}
