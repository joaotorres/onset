import { Controller } from "@hotwired/stimulus"

// Waiting invite (SPEC §8): Share link on touch screens with Web Share,
// Copy link elsewhere, and the QR sheet.
export default class extends Controller {
  static targets = ["link", "label", "copyIcon", "shareIcon", "sheet"]
  static values = { url: String, code: String }

  connect() {
    this.sharing = typeof navigator.share === "function" && window.matchMedia("(pointer: coarse)").matches
    this.reset()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  async share() {
    if (this.sharing) {
      try {
        await navigator.share({ url: this.urlValue, title: `Room ${this.codeValue}` })
        return
      } catch (error) {
        if (error.name === "AbortError") return
      }
    }
    try {
      await navigator.clipboard.writeText(this.urlValue)
      this.flash("Copied ✓")
    } catch {
      this.flash("Couldn't copy")
    }
  }

  open() {
    this.sheetTarget.showModal()
  }

  close() {
    this.sheetTarget.close()
  }

  flash(text) {
    clearTimeout(this.timer)
    this.labelTarget.textContent = text
    this.copyIconTarget.classList.add("hidden")
    this.shareIconTarget.classList.add("hidden")
    this.timer = setTimeout(() => this.reset(), 2000)
  }

  reset() {
    this.labelTarget.textContent = this.sharing ? "Share link" : "Copy link"
    this.copyIconTarget.classList.toggle("hidden", this.sharing)
    this.shareIconTarget.classList.toggle("hidden", !this.sharing)
  }
}
