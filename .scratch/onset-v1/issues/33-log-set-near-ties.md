# 33: Log SET! near-ties

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

Log SET! near-ties: when a SET! call loses the race because another claim is already running, log how many ms after that claim started the losing call arrived (not for players locked out or calls rejected for other reasons). Add a note under §14 Future Work to evaluate those logs once enough games have been played, and from them decide whether to claim on pointerdown instead of click, send claims over the WebSocket or add lag compensation (tap timestamps plus a short collection window), with the trade-offs of each.

Settled in conversation: the server already judges claims in arrival order (`Game#try_claim!` under `with_lock`). The unfairness, if any, comes before the server: network differences between phones, `click` firing on finger release, an occasional cold connection. The log measures arrival gaps, not tap gaps, which is the right signal for "could the order have flipped". No change to who wins a claim in this ticket.

Trade-offs to record in the §14 note:

- **Claim on pointerdown**: removes the release delay that varies per player, but fires on a scroll start or a brush (stray claims cost −1), loses slide-off-to-cancel, risks a card being picked twice when the click lands on the redrawn screen (§8 "only the first tap counts"), and needs `click` kept for the keyboard. If done, SET! button only.
- **Claims over the WebSocket**: skips a possible handshake and HTTP overhead, but the gain is unmeasured, mobile browsers drop the socket on suspended tabs so HTTP stays as a fallback (two claim paths), and it needs the custom channel §9 says to avoid.
- **Lag compensation**: the only option that cancels network differences, but every claim starts about 150 ms later, it trusts device-reported tap times (needs clock sync for correctness and a clamp against faked early stamps), still misses device input speed and is harder to test.
- Also worth weighing then: players see a new board at different moments, a head start none of these fix; and "first to reach the server" is a defensible rule for a casual party game.

## Comments
