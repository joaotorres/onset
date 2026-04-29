# CLAUDE.md

The full design lives in `SPEC.md` — read it before starting any non-trivial task.

## Conventions

- Tests: RSpec
- Formatting: Standard Ruby (`bundle exec standardrb`).
- Commits: one per implementation step from SPEC.md §15. Reference the step number in the message.
- Don't introduce Redis, Postgres, or external services without flagging in chat first — the spec is intentionally SQLite-only.
