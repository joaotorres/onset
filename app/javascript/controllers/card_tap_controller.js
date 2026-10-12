import { Controller } from "@hotwired/stimulus"

// The card tapped on the idle board, waiting for this player's claim view
// (card-selection) to select it. Lives in memory: Turbo Streams never reload.
let pendingCardId = null

export function takePendingCardTap() {
  const id = pendingCardId
  pendingCardId = null
  return id
}

// Idle board: each card is a submit button of the SET! claim form (§8).
export default class extends Controller {
  connect() {
    // A tap that lost the race, or a stale one, must not reach a later claim.
    pendingCardId = null
    this.tapped = false
  }

  tap(event) {
    if (this.tapped) {
      event.preventDefault() // only the first tap counts until the screen changes
      return
    }
    this.tapped = true
    pendingCardId = parseInt(event.currentTarget.dataset.cardId)
  }
}
