# CLAUDE.md

The full design lives in `SPEC.md`. Read it before starting any non-trivial task. Section numbers in this file (e.g. §15) refer to that spec.

## Workflow

- **One step at a time.** Implement only the step the user names from SPEC.md §15. Do not proceed to the next step unless explicitly asked.
- **Acceptance is the commit gate.** Each step in §15 ends with an **Acceptance:** criterion. A step is not done until that criterion is met. If a criterion can't be verified locally (e.g., production deploy), say so and tell the user what to verify.
- **Plan before coding for any step that touches more than two files.** Post the plan in chat, wait for an OK, then implement.
- **Tests live in the same commit as the behavior.** Don't defer them.
- **Commit message format:** `Step N: <short description>` matching the step's goal in §15.
- **Stop on ambiguity.** If the spec doesn't decide something the step requires, ask in chat. Do not guess.

## Stack guardrails

The spec is intentionally minimal. Do not add the following without flagging in chat first:

- Redis, Sidekiq, or any external broker. Use Solid Queue and Solid Cable (SQLite-backed), already wired up.
- PostgreSQL, MySQL, or any managed DB. SQLite for primary, cable, queue, cache — all on the mounted disk.
- Devise or any auth gem. v1 is guests-only; the v1.5 plan in §14 uses Rails 8's built-in auth + magic links.
- esbuild, webpack, bun, or any JS bundler. Stay on Importmap.
- React, Vue, or any SPA framework. Hotwire (Turbo + Stimulus) is the rule.
- View component libraries (ViewComponent, Phlex). Plain ERB partials.
- RSpec. Minitest is the framework.
- Sass, PostCSS plugins, etc. Tailwind only.

## Rails 8 conventions

- Use `bin/rails`, not `bundle exec rails`.
- Stimulus controllers in `app/javascript/controllers/`, auto-registered.
- Turbo Stream broadcasts via `broadcasts_to` model callbacks per §7. Avoid custom Action Cable channels unless §7 says otherwise.
- ERB partials in `app/views/<resource>/_partial.html.erb`. Cards in `app/views/cards/_card.html.erb` per §10.
- System tests with the default headless Chrome driver. They're worth writing for the realtime sync step (Step 9).

## Code style

- Format with `bundle exec standardrb --fix` before commit.
- Ruby idioms: prefer guard clauses over nested conditionals; small methods on rich models; service objects only when a model gets unwieldy.
- Database changes are migrations, never schema edits. One migration per step that needs schema changes.

## When in doubt

Re-read the relevant spec section. If still unclear, ask in chat with a specific question and a proposed answer. Do not invent details that drift from the spec.
