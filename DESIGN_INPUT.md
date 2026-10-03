# SET Online - Design Input

## Product Overview
A real-time multiplayer web version of the board game Set.

- One shared screen (TV or laptop) shows the game board
- Players join using their phones via QR code
- Phones act as controllers
- Fast-paced, competitive, reaction-based gameplay

---

## Core Game Rules (Simplified)
- The board shows 12 cards (can expand to 15 or 18)
- A valid "Set" is 3 cards that satisfy the game rules
- Players race to press "SET!"
- First player gets a 5 second window to select 3 cards

### Outcomes
- Correct set:
  - +1 point
  - Cards replaced
- Wrong set:
  - -1 point
  - 5 second lockout
- Timeout:
  - Treated as wrong

---

## No Set Flow
- A player can press "No Set"
- Starts a 15 second countdown
- Any player can cancel by pressing "SET!"
- If countdown completes:
  - 3 more cards are added (max 18)

---

## Game States
- Waiting for players
- Playing (idle)
- Set claimed (locked)
- Selecting cards (5s timer)
- Correct set feedback
- Wrong set feedback
- Player lockout
- No-set countdown
- Board expanded
- Game finished

---

## Platforms

### 1. Shared Screen (TV / Desktop)
Purpose:
- Display board
- Display scores
- Show game state and feedback
- Allow players to join (QR code)

### 2. Phone Controller
Purpose:
- Input device for players
- Minimal, fast interaction
- Immediate feedback

---

## UX Priorities

1. Clarity under time pressure
2. Immediate feedback on actions
3. Clear indication of:
   - Who is active
   - When input is locked
   - Remaining time
4. Large touch targets (mobile)
5. Minimal cognitive load

---

## Visual Tone

- Clean, modern, minimal
- High contrast
- Game-like but not childish
- Fast and responsive feeling
- Subtle animations for feedback

---

## Constraints

- Real-time updates
- Responsive (mobile + large screen)
- Web-based (no native apps)
- Must be component-friendly for implementation

---

## What You Need to Produce

- Screen designs
- Component system
- Interaction states
- Visual hierarchy
- Responsive behavior

Focus on usability over decoration.
