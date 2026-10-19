import { Controller } from "@hotwired/stimulus"

const EVENTS = {
  "waiting>playing": "game_started",
  "ended>playing": "game_restarted",
  "playing>ended": "game_finished"
}

// Game state events from a player screen (TrackingHelper#game_events_tag).
// The state arrives by broadcast and every update re-renders this element, so
// an event is a change of status this screen saw, remembered per game in
// sessionStorage. The screen also notes when it saw play start, which gives
// game_finished its duration_seconds; a screen that did not see the start
// leaves it out.
export default class extends Controller {
  static values = { code: String, status: String, reporter: Boolean, props: Object }

  connect() {
    const key = `onset.game.${this.codeValue}`
    const seen = read(key)
    const now = { status: this.statusValue, startedAt: seen?.startedAt }

    if (seen && seen.status !== now.status) {
      if (now.status === "playing") now.startedAt = Date.now()
      const name = EVENTS[`${seen.status}>${now.status}`]
      if (name && this.reporterValue) {
        const props = { ...this.propsValue }
        if (name === "game_finished" && seen.startedAt) props.duration_seconds = Math.round((Date.now() - seen.startedAt) / 1000)
        window.jtTrack?.(name, props)
      }
    }
    write(key, now)
  }
}

function read(key) {
  try {
    return JSON.parse(sessionStorage.getItem(key))
  } catch {
    return null
  }
}

function write(key, value) {
  try {
    sessionStorage.setItem(key, JSON.stringify(value))
  } catch {}
}
