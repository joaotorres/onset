import { Controller } from "@hotwired/stimulus"

// The add-bot control (SPEC, AI opponent > Adding a bot). The button's own
// form posts the add; this only sends bot_added with the level on the tap.
// The control never changes while the add is on its way: the broadcast
// shows the bot.
export default class extends Controller {
  track({ params }) {
    window.jtTrack?.("bot_added", { level: params.level })
  }
}
