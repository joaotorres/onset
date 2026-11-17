import { Controller } from "@hotwired/stimulus"

// SPEC.md §8, Settings menu, and §10, Themes. The theme lives in the `theme`
// cookie and on <html data-theme>; Match device deletes both and leaves the
// page to the media query. Card colors works the same way (pickCardColors).
// Picking never reaches the server.
const THEME_COLORS = { light: "#F9FAFB", dark: "#030712" }
const YEAR = 60 * 60 * 24 * 365

export default class extends Controller {
  static targets = ["button", "menu", "shield"]

  connect() {
    this.syncRadios()
    this.applyThemeColor(this.theme)
  }

  // §10 Themes: every Turbo render (a link or form visit, its preview, Back
  // or Forward from the cache) takes <html>'s picks from the cookies as they
  // are now, with ThemesHelper's rule, so a pick made in another tab shows.
  // Turbo keeps the old <html>, and a cached snapshot holds stale values.
  syncFromCookies() {
    const root = document.documentElement
    const theme = this.cookie("theme")
    if (theme === "light" || theme === "dark") root.dataset.theme = theme
    else delete root.dataset.theme
    if (this.cookie("card_colors") === "colorblind") root.dataset.cardColors = "colorblind"
    else delete root.dataset.cardColors
  }

  cookie(name) {
    const pair = document.cookie.split("; ").find((c) => c.startsWith(`${name}=`))
    return pair?.slice(name.length + 1)
  }

  get open() {
    return !this.menuTarget.hidden
  }

  get theme() {
    return document.documentElement.dataset.theme || "device"
  }

  toggle() {
    this.open ? this.close(true) : this.show()
  }

  show() {
    this.syncRadios()
    this.menuTarget.hidden = false
    this.shieldTarget.hidden = false
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.menuTarget.querySelector('input[name="theme"]:checked')?.focus()
  }

  close(returnFocus) {
    this.menuTarget.hidden = true
    this.shieldTarget.hidden = true
    this.buttonTarget.setAttribute("aria-expanded", "false")
    if (returnFocus) this.buttonTarget.focus()
  }

  escape() {
    if (this.open) this.close(true)
  }

  closeButton() {
    this.close(true)
  }

  // A tap outside: only closes, focus stays where it was.
  dismiss(event) {
    event?.preventDefault()
    if (this.open) this.close(false)
  }

  pick(event) {
    const theme = event.target.value
    if (theme === this.theme) return

    this.applyTheme(theme)
    window.jtTrack?.("theme_changed", { theme })
  }

  get cardColors() {
    return document.documentElement.dataset.cardColors || "classic"
  }

  // §10 Palette: Color-blind lives in the `card_colors` cookie and on
  // <html data-card-colors>; Classic deletes both. CSS does the rest.
  pickCardColors(event) {
    const cardColors = event.target.value
    if (cardColors === this.cardColors) return

    const root = document.documentElement
    if (cardColors === "colorblind") {
      root.dataset.cardColors = cardColors
      document.cookie = `card_colors=${cardColors}; path=/; max-age=${YEAR}; samesite=lax`
    } else {
      delete root.dataset.cardColors
      document.cookie = "card_colors=; path=/; max-age=0; samesite=lax"
    }
    window.jtTrack?.("card_colors_changed", { card_colors: cardColors })
  }

  applyTheme(theme) {
    const root = document.documentElement
    if (theme === "device") {
      delete root.dataset.theme
      document.cookie = "theme=; path=/; max-age=0; samesite=lax"
    } else {
      root.dataset.theme = theme
      document.cookie = `theme=${theme}; path=/; max-age=${YEAR}; samesite=lax`
    }
    this.applyThemeColor(theme)
  }

  // Mirrors ThemesHelper#theme_color_tags.
  applyThemeColor(theme) {
    document.querySelectorAll('meta[name="theme-color"]').forEach((meta) => meta.remove())
    const metas = theme === "device"
      ? [[THEME_COLORS.light, "(prefers-color-scheme: light)"], [THEME_COLORS.dark, null]]
      : [[THEME_COLORS[theme], null]]
    const anchor = document.querySelector('meta[name="viewport"]')
    metas.reverse().forEach(([content, media]) => {
      const meta = document.createElement("meta")
      meta.name = "theme-color"
      meta.content = content
      if (media) meta.media = media
      anchor.after(meta)
    })
  }

  syncRadios() {
    this.element.querySelectorAll('input[name="theme"]').forEach((radio) => {
      radio.checked = radio.value === this.theme
    })
    this.element.querySelectorAll('input[name="card_colors"]').forEach((radio) => {
      radio.checked = radio.value === this.cardColors
    })
  }
}
