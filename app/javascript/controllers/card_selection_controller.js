import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "input", "form"]

  connect() {
    this.selected = []
    this.submitTimer = null
  }

  disconnect() {
    clearTimeout(this.submitTimer)
  }

  toggle(event) {
    if (this.submitTimer) return // grace window in progress, ignore taps

    const card = event.currentTarget
    const id = parseInt(card.dataset.cardId)

    if (this.selected.includes(id)) {
      this.selected = this.selected.filter(x => x !== id)
      card.classList.remove("ring-4", "ring-blue-400", "scale-95")
    } else if (this.selected.length < 3) {
      this.selected = [...this.selected, id]
      card.classList.add("ring-4", "ring-blue-400", "scale-95")

      if (this.selected.length === 3) {
        this.formTarget.classList.add("opacity-50", "pointer-events-none")
        const snapshot = [...this.selected]
        this.submitTimer = setTimeout(() => {
          this.inputTarget.value = JSON.stringify(snapshot)
          this.formTarget.requestSubmit()
        }, 250)
      }
    }
  }
}
