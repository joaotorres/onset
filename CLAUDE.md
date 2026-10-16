# CLAUDE.md

The full design lives in `SPEC.md`. Read it before starting any non-trivial task. Section numbers in this file (e.g. §15) refer to that spec.

## Workflow

Work moves from request to deploy through the skills-loop plugin. Config in
`docs/agents/skills-loop.conf`. The commands and what each does are in the
plugin's `README.md`, the contract in its `docs/workflow.md`
(`${SKILLS_LOOP:-~/Projects/skills-loop}`); neither is copied here, so a
plugin change never leaves this file stale. `docs/loop-log.md` records each
step, newest first.

When triaging, splitting, implementing, reviewing or designing a ticket,
call the Skill tool with `loop-rules`: the gates, the implement loop, the
headless exit, the design pass, the chain and the log live there. If it is not available in
this session, stop and say so.

## Stack guardrails

The spec is intentionally minimal. Do not add the following without flagging in chat first:

- Redis, Sidekiq, or any external broker. Use Solid Queue and Solid Cable (SQLite-backed), already wired up.
- PostgreSQL, MySQL, or any managed DB. SQLite for primary, cable, queue, cache — all on the mounted disk.
- Devise or any auth gem. v1 is guests-only; the v1.5 plan in §14 uses Rails 8's built-in auth + magic links.
- esbuild, webpack, bun, or any JS bundler. Stay on Importmap.
- React, Vue, or any SPA framework. Hotwire (Turbo + Stimulus) is the rule.
- View component libraries (ViewComponent, Phlex). Plain ERB partials.
- Sass, PostCSS plugins, etc. Tailwind only.

## Testing

- Use RSpec (`rspec-rails`) for all tests: unit, request, and system specs.
- Specs live in `spec/`. Run with `bundle exec rspec`.
- System specs use the default headless Chrome driver (Capybara + Selenium).

## Rails 8 conventions

- Use `bin/rails`, not `bundle exec rails`.
- Stimulus controllers in `app/javascript/controllers/`, auto-registered.
- Turbo Stream broadcasts via `broadcasts_to` model callbacks per §7. Avoid custom Action Cable channels unless §7 says otherwise.
- ERB partials in `app/views/<resource>/_partial.html.erb`. Cards in `app/views/cards/_card.html.erb` per §10.
- System specs (RSpec + Capybara) with the default headless Chrome driver. Worth writing for the realtime sync step (Step 9).

## Code style

- Format with `bundle exec standardrb --fix` before commit.
- Ruby idioms: prefer guard clauses over nested conditionals; small methods on rich models; service objects only when a model gets unwieldy.
- Database changes are migrations, never schema edits. One migration per ticket that needs schema changes.

## When in doubt

Re-read the relevant spec section. Do not invent details that drift from the spec.

## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), recorded as a `Status:` line in each issue file. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
