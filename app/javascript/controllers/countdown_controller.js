import { Controller } from "@hotwired/stimulus"

const CIRCUMFERENCE = 2 * Math.PI * 45 // ≈ 282.7

export default class extends Controller {
  static targets = ["display", "ring"]
  static values = { startedAt: String, duration: Number }

  connect() {
    this.rafId = null
    this.tick()
  }

  disconnect() {
    cancelAnimationFrame(this.rafId)
  }

  tick() {
    this.update()
    this.rafId = requestAnimationFrame(() => this.tick())
  }

  update() {
    const elapsed = (Date.now() - new Date(this.startedAtValue)) / 1000
    const remaining = Math.max(0, this.durationValue - elapsed)

    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = Math.ceil(remaining)
    }

    if (this.hasRingTarget) {
      const progress = Math.min(elapsed / this.durationValue, 1)
      this.ringTarget.style.strokeDashoffset = CIRCUMFERENCE * progress
    }
  }
}
