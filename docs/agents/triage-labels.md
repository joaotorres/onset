# Triage Labels

The skills speak in terms of five canonical triage roles. This file maps those roles to the actual label strings used in this repo's issue tracker.

| Label in mattpocock/skills | Label in our tracker | Meaning                                  |
| -------------------------- | -------------------- | ---------------------------------------- |
| `needs-triage`             | `needs-triage`       | Maintainer needs to evaluate this issue  |
| `needs-info`               | `needs-info`         | Waiting on reporter for more information |
| `ready-for-agent`          | `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`    | Requires human implementation            |
| `wontfix`                  | `wontfix`            | Will not be actioned                     |

Labels outside the skills' vocabulary, because the ticket files are also the
progress record:

| Label         | Meaning                                                              |
| ------------- | -------------------------------------------------------------------- |
| `in-progress` | An agent has started this ticket. Set before any work                |
| `done`        | Implemented, and the ticket's exact Verification command passed      |
| `deployed`    | `done`, and included in a tagged deploy. Set by `bin/deploy` only    |
| `split`       | Broken into child tickets by /to-tickets. The record, never built    |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from this table.

Edit the "Label in our tracker" column to match whatever vocabulary you actually use.

## skills-loop

This repo runs the skills-loop workflow (`docs/agents/skills-loop.conf`).
Before moving a ticket to any status, call the Skill tool with `loop-rules`:
it holds the ready-for-agent gates, the Kind test and the split rule. If that skill
is not available in this session, stop and say the skills-loop plugin is not
loaded. Do not triage without it.
