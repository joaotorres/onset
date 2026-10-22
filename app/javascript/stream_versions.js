// SPEC.md §7, Screens ignore broadcasts older than what they show.
// Action Cable can deliver two broadcasts out of order, so a replace whose
// root carries a data-version older than the region on the page is dropped.
// Equal versions render: the timer jobs rebroadcast with no write.
document.addEventListener("turbo:before-stream-render", (event) => {
  const stream = event.target
  if (stream.action !== "replace") return

  const incoming = stream.templateContent?.firstElementChild?.dataset?.version
  const current = document.getElementById(stream.target)?.dataset?.version
  if (incoming === undefined || current === undefined) return

  if (Number(incoming) < Number(current)) event.detail.render = () => {}
})
