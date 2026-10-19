import { Controller } from "@hotwired/stimulus"

// Custom PostHog events through window.jtTrack, which the layout's
// jt_telemetry tag defines. Events a server action handed over
// (TracksEvents) go out on connect, then the value is emptied so a Turbo
// restoration visit to the cached page does not send them again.
export default class extends Controller {
  static values = { events: Array }

  connect() {
    this.eventsValue.forEach(([name, props]) => window.jtTrack?.(name, props))
    this.eventsValue = []
  }
}
