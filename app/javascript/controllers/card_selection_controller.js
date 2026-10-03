import { Controller } from "@hotwired/stimulus"

const SELECTED = ["ring-4", "ring-blue-400", "scale-95"]
const EMPTY_SLOT = ["border-2", "border-dashed", "border-gray-700"]

export default class extends Controller {
  static targets = ["card", "input", "form", "slot", "count"]

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
      card.classList.remove(...SELECTED)
      card.setAttribute("aria-pressed", "false")
      this.emptySlot(id)
    } else if (this.selected.length < 3) {
      this.selected = [...this.selected, id]
      card.classList.add(...SELECTED)
      card.setAttribute("aria-pressed", "true")
      this.fillSlot(id, card)

      if (this.selected.length === 3) {
        this.formTarget.classList.add("opacity-50", "pointer-events-none")
        const snapshot = [...this.selected]
        this.submitTimer = setTimeout(() => {
          this.inputTarget.value = JSON.stringify(snapshot)
          this.formTarget.requestSubmit()
        }, 250)
      }
    }

    this.countTargets.forEach(el => { el.textContent = this.selected.length })
  }

  fillSlot(id, card) {
    const slot = this.slotTargets.find(s => !s.dataset.slotCardId)
    const svg = card.querySelector("svg")
    if (!slot || !svg) return

    slot.dataset.slotCardId = id
    slot.classList.remove(...EMPTY_SLOT)
    slot.replaceChildren(svg.cloneNode(true))
  }

  emptySlot(id) {
    const slot = this.slotTargets.find(s => s.dataset.slotCardId === String(id))
    if (!slot) return

    delete slot.dataset.slotCardId
    slot.classList.add(...EMPTY_SLOT)
    slot.replaceChildren(String(this.slotTargets.indexOf(slot) + 1))
  }
}
