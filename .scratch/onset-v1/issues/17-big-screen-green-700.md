# 17: Big screen green buttons on green-700

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Big screen Start game and Play again use green-700 under white text, per design system v2

docs/design-system.md v2 added the rule that white text on green uses `green-700` (`#15803D`), since `green-600` is about 3.3:1, and listed these two buttons under Known gaps: `games/_start_button` (Start game) and `games/_board` (Play again) both use `bg-green-600 hover:bg-green-500` with white text. The user chose to leave them out of tickets 07 to 10 and fix them in a ticket of their own.

## Comments

Decided: Kind behavioural, because the green-700 rule and token are already in docs/design-system.md v2 and nothing new is drawn. Instead of: visual, waiting on a design pass.
