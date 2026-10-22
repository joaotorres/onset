// SPEC.md §7, Screens ignore broadcasts older than what they show.
// Action Cable can deliver two broadcasts out of order, so a replace whose
// root carries a data-version older than the region on the page is dropped.
// Equal versions render: the timer jobs rebroadcast with no write.
// Turbo fires this event before the next repaint and renders after it, so the
// page is compared at render time: two streams in one frame see each other.
document.addEventListener("turbo:before-stream-render", (event) => {
  const stream = event.target
  if (stream.action !== "replace") return

  const incoming = stream.templateContent?.firstElementChild?.dataset?.version
  if (incoming === undefined) return

  const render = event.detail.render
  event.detail.render = (element) => {
    const current = document.getElementById(stream.target)?.dataset?.version
    if (current !== undefined && Number(incoming) < Number(current)) return
    return render(element)
  }
})
