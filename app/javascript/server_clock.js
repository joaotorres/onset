// SPEC.md §6, Server-side timers: countdowns follow the server's clock.
// One offset per page load, shared by every countdown and kept across the
// stream redraws that replace them. 0 until the first measurement lands.
const SAMPLES = 3

let offset = 0

export function now() {
  return Date.now() + offset
}

async function sample() {
  const sent = Date.now()
  const response = await fetch("/clock", { cache: "no-store", headers: { Accept: "application/json" } })
  const received = Date.now()
  if (!response.ok) throw new Error(`clock ${response.status}`)
  const { now } = await response.json()
  return { roundTrip: received - sent, offset: now - (sent + received) / 2 }
}

// Fetches the clock a few times in sequence and keeps the sample with the
// shortest round trip. A failed fetch leaves the offset as it was.
export async function sync() {
  try {
    let best = null
    for (let i = 0; i < SAMPLES; i++) {
      const s = await sample()
      if (!best || s.roundTrip < best.roundTrip) best = s
    }
    offset = best.offset
  } catch (_error) {
    // Display only: the device clock is the fallback.
  }
  return offset
}

sync()
