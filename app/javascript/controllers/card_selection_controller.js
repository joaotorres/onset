import { Controller } from "@hotwired/stimulus"
import { takePendingCardTap } from "controllers/card_tap_controller"

const SELECTED = ["ring-4", "ring-blue-400", "scale-95"]
const EMPTY_SLOT = ["border-2", "border-dashed", "border-gray-700"]

// The current claim's picks and its one-at-a-time sending live outside the
// controller, keyed by the claim URL: a redraw mid-claim replaces the
// controller while a pick may still be on its way, and the new one carries on
// from the latest picks rather than the ones rendered before that pick landed (§11).
let current = null

function claimFor(url, renderedPicks) {
  if (!current || current.url !== url) {
    current = { url, selected: renderedPicks, inFlight: false, dirty: false, submitted: false }
  }
  return current
}

// One request at a time, each carrying the whole selection, so the picks
// arrive in order; the latest selection goes when the previous returns,
// whichever controller sent the previous one.
function request(url, method, ids) {
  return fetch(url, {
    method,
    headers: {
      "Content-Type": "application/json",
      "Accept": "text/vnd.turbo-stream.html, text/html",
      "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content || ""
    },
    body: JSON.stringify({ card_ids: ids }),
    credentials: "same-origin"
  })
}

async function send(claim) {
  if (claim.inFlight) {
    claim.dirty = true
    return
  }

  claim.inFlight = true
  try {
    await request(claim.url, "PATCH", claim.selected)
  } catch (_error) {
    // A lost request: the next tap sends the whole selection again.
  } finally {
    claim.inFlight = false
    if (claim.dirty) {
      claim.dirty = false
      send(claim)
    }
  }
}

// Claiming (mine): a tap picks or unpicks a card, up to three, and sends the
// whole selection to the server. Submit, enabled at exactly three picks, sends
// the selection to be judged at once and freezes the screen until the
// resolving broadcast replaces it; otherwise the time running out judges (§11).
export default class extends Controller {
  static targets = ["card", "slot", "count", "hint", "submit"]
  static values = { url: String, submitUrl: String }

  connect() {
    // The picks are server state: a redraw renders them aria-pressed. Within
    // the same claim, the page's latest picks win over that render.
    const rendered = this.cardTargets
      .filter(card => card.getAttribute("aria-pressed") === "true")
      .map(card => parseInt(card.dataset.cardId))
    this.claim = claimFor(this.urlValue, rendered)
    this.showPicks()

    // A claim started by tapping an idle card opens with that card picked.
    const tapped = takePendingCardTap()
    const card = this.cardTargets.find(c => parseInt(c.dataset.cardId) === tapped)
    if (card && !this.selected.includes(tapped)) this.toggleCard(card)
  }

  get selected() {
    return this.claim.selected
  }

  toggle(event) {
    this.toggleCard(event.currentTarget)
  }

  toggleCard(card) {
    if (this.claim.submitted) return
    const id = parseInt(card.dataset.cardId)

    if (this.selected.includes(id)) {
      this.claim.selected = this.selected.filter(x => x !== id)
      this.markCard(card, false)
      this.emptySlot(id)
    } else if (this.selected.length < 3) {
      this.claim.selected = [...this.selected, id]
      this.markCard(card, true)
      this.fillSlot(id, card)
    } else {
      return
    }

    this.updateCount()
    send(this.claim)
  }

  // Sends the whole selection at once, whatever pick request is in flight.
  // Only a request that never reaches the server lifts the freeze; any
  // response leaves the screen to the broadcast, or to the timer.
  async submit() {
    if (this.claim.submitted || this.selected.length !== 3) return

    const claim = this.claim
    claim.submitted = true
    this.updateCount()
    try {
      await request(this.submitUrlValue, "POST", claim.selected)
    } catch (_error) {
      claim.submitted = false
      if (this.claim === claim && this.element.isConnected) this.updateCount()
    }
  }

  // Marks the board, tray and count to match the picks.
  showPicks() {
    this.cardTargets.forEach(card => {
      this.markCard(card, this.selected.includes(parseInt(card.dataset.cardId)))
    })
    this.slotTargets.forEach(slot => {
      if (slot.dataset.slotCardId) this.emptySlot(parseInt(slot.dataset.slotCardId))
    })
    this.selected.forEach(id => {
      const card = this.cardTargets.find(c => parseInt(c.dataset.cardId) === id)
      if (card) this.fillSlot(id, card)
    })
    this.updateCount()
  }

  markCard(card, picked) {
    if (picked) {
      card.classList.add(...SELECTED)
    } else {
      card.classList.remove(...SELECTED)
    }
    card.setAttribute("aria-pressed", String(picked))
  }

  // The n/3 count, the hint, Submit and the board's freeze, from the picks.
  updateCount() {
    const count = this.selected.length
    const submitted = this.claim.submitted
    const state = submitted ? "submitted" : (count === 3 ? "enabled" : "disabled")
    const hint = submitted ? "Judging…" : (count === 3 ? "Tap Submit" : "Tap 3 cards")

    this.countTargets.forEach(el => { el.textContent = count })
    this.hintTargets.forEach(el => { el.textContent = hint })
    this.cardTargets.forEach(card => { card.disabled = submitted })
    this.submitTargets.forEach(button => {
      button.dataset.state = state
      button.disabled = state !== "enabled"
      button.querySelector("[data-submit-label]").textContent = submitted ? "Submitted" : "Submit"
      if (submitted) {
        button.setAttribute("aria-label", "Submitted, waiting for the result")
      } else {
        button.removeAttribute("aria-label")
      }
    })
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
