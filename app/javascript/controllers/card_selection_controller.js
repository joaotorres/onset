import { Controller } from "@hotwired/stimulus"
import { takePendingCardTap } from "controllers/card_tap_controller"

const SELECTED = ["ring-4", "ring-blue-400", "scale-95"]
const EMPTY_SLOT = ["border-2", "border-dashed", "border-gray-700"]

// Claiming (mine): a tap picks or unpicks a card, up to three, and sends the
// whole selection to the server. Nothing is judged until the time runs out (§11).
export default class extends Controller {
  static targets = ["card", "slot", "count"]
  static values = { url: String }

  connect() {
    this.inFlight = false
    this.dirty = false

    // The picks are server state: a redraw renders them aria-pressed, so
    // the tray and the count are refilled from the board.
    this.selected = []
    this.cardTargets
      .filter(card => card.getAttribute("aria-pressed") === "true")
      .forEach(card => {
        const id = parseInt(card.dataset.cardId)
        this.selected.push(id)
        this.fillSlot(id, card)
      })
    this.updateCount()

    // A claim started by tapping an idle card opens with that card picked.
    const tapped = takePendingCardTap()
    const card = this.cardTargets.find(c => parseInt(c.dataset.cardId) === tapped)
    if (card && !this.selected.includes(tapped)) this.toggleCard(card)
  }

  toggle(event) {
    this.toggleCard(event.currentTarget)
  }

  toggleCard(card) {
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
    } else {
      return
    }

    this.updateCount()
    this.send()
  }

  // One request at a time, each carrying the whole selection, so the picks
  // arrive in order; the latest selection goes when the previous returns.
  async send() {
    if (this.inFlight) {
      this.dirty = true
      return
    }

    this.inFlight = true
    try {
      await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html, text/html",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content || ""
        },
        body: JSON.stringify({ card_ids: this.selected }),
        credentials: "same-origin"
      })
    } catch (_error) {
      // A lost request: the next tap sends the whole selection again.
    } finally {
      this.inFlight = false
      if (this.dirty) {
        this.dirty = false
        this.send()
      }
    }
  }

  updateCount() {
    this.countTargets.forEach(el => { el.textContent = this.selected.length })
  }

  fillSlot(id, card) {
    const slot = this.slotTargets.find(s => !s.dataset.slotCardId)
    const svg = card.querySelector("svg")
    if (!slot || !svg) return

    slot.dataset.slotCardId = id
    slot.classList.remove(...EMPTY_SLOT)
    slot.replaceChildren(this.copyWithFreshIds(svg))
  }

  // A copy keeps its pattern ids unique (§10): a browser resolves url(#id)
  // to the first match, and the tray can sit hidden ahead of the grid.
  copyWithFreshIds(svg) {
    const copy = svg.cloneNode(true)
    const suffix = Math.random().toString(36).slice(2, 10)

    copy.querySelectorAll("[id]").forEach(el => {
      const oldId = el.id
      el.id = `${oldId}-tray-${suffix}`
      copy.querySelectorAll(`[fill="url(#${oldId})"]`).forEach(shape => {
        shape.setAttribute("fill", `url(#${el.id})`)
      })
    })
    return copy
  }

  emptySlot(id) {
    const slot = this.slotTargets.find(s => s.dataset.slotCardId === String(id))
    if (!slot) return

    delete slot.dataset.slotCardId
    slot.classList.add(...EMPTY_SLOT)
    slot.replaceChildren(String(this.slotTargets.indexOf(slot) + 1))
  }
}
