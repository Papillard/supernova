import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="student-selector"
export default class extends Controller {
  static targets = ["select", "newFields", "levelDisplay", "firstNameInput", "birthYearInput"]
  static values = { students: Array }

  connect() {
    // Si pas de select (pas d'étudiants existants), les champs sont déjà visibles
    if (!this.hasSelectTarget) {
      return
    }
    this.updateVisibility()
  }

  toggle(event) {
    this.updateVisibility()
    // Si on sélectionne un étudiant existant, mettre à jour le niveau
    if (this.hasSelectTarget && this.selectTarget.value && this.selectTarget.value !== "new" && this.selectTarget.value !== "") {
      this.updateLevelFromStudent()
    }
  }

  updateVisibility() {
    // Si pas de select, ne rien faire (champs déjà visibles)
    if (!this.hasSelectTarget) {
      return
    }

    const isNew = this.selectTarget.value === "new"

    if (isNew) {
      // Afficher les champs de création, garder le select visible
      this.newFieldsTarget.classList.remove("hidden")
      // Activer les champs de création
      if (this.hasFirstNameInputTarget) {
        this.firstNameInputTarget.disabled = false
        this.firstNameInputTarget.required = true
      }
      if (this.hasBirthYearInputTarget) {
        this.birthYearInputTarget.disabled = false
        this.birthYearInputTarget.required = true
      }
      // Réinitialiser le niveau
      if (this.hasLevelDisplayTarget) {
        this.levelDisplayTarget.value = ""
      }
    } else {
      // Masquer les champs de création, garder le select visible
      this.newFieldsTarget.classList.add("hidden")
      // Désactiver les champs de création pour éviter la soumission
      if (this.hasFirstNameInputTarget) {
        this.firstNameInputTarget.disabled = true
        this.firstNameInputTarget.required = false
        this.firstNameInputTarget.value = ""
      }
      if (this.hasBirthYearInputTarget) {
        this.birthYearInputTarget.disabled = true
        this.birthYearInputTarget.required = false
        this.birthYearInputTarget.value = ""
      }
      // Mettre à jour le niveau si un étudiant est sélectionné
      if (this.selectTarget.value && this.selectTarget.value !== "" && this.selectTarget.value !== "new") {
        this.updateLevelFromStudent()
      }
    }
  }

  updateLevelFromStudent() {
    if (!this.hasLevelDisplayTarget) return

    const studentId = parseInt(this.selectTarget.value)
    if (!studentId || isNaN(studentId)) return

    const students = this.studentsValue || []
    const student = students.find(s => s.id === studentId)

    if (student && student.level) {
      // Mapper le niveau de l'étudiant vers la valeur du select
      const levelMapping = {
        'primaire': 'primaire',
        'college': 'college',
        'lycee': 'lycee',
        'prepa': 'prepa',
        'bts': 'bts',
        'sup': 'sup'
      }

      this.levelDisplayTarget.value = levelMapping[student.level] || student.level
    } else {
      this.levelDisplayTarget.value = ""
    }
  }

  updateLevelFromBirthYear(event) {
    if (!this.hasLevelDisplayTarget) return

    const birthYear = parseInt(event.target.value)
    if (!birthYear || isNaN(birthYear)) {
      this.levelDisplayTarget.value = ""
      return
    }

    const currentYear = new Date().getFullYear()
    const age = currentYear - birthYear

    // Mapper l'âge vers la valeur du select (pas le label)
    let levelValue = ""
    if (age >= 0 && age <= 10) {
      levelValue = "primaire"
    } else if (age >= 11 && age <= 14) {
      levelValue = "college"
    } else if (age >= 15 && age <= 17) {
      levelValue = "lycee"
    } else if (age >= 18 && age <= 20) {
      levelValue = "prepa"
    } else if (age > 20) {
      levelValue = "sup"
    }

    this.levelDisplayTarget.value = levelValue
  }
}
