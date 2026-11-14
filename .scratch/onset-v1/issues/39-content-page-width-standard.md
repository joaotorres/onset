# 39: Content pages: width standard (944 px content, 65ch prose)

Status: needs-triage
Kind: visual
Blocked by:
Priority:
Model:
Effort:
Changelog:

## Request

Width standard for content pages (jt-playbook `LAYOUT.md`, onset rows, adopted 2026-11-14, commit e835296; handoff 690f02).

How-to-play and other content pages keep 944 px (`max-w-5xl`), an agreed exception because of the card diagrams. Their padding moves from the max-width element to an outer wrapper (`px-5 sm:px-8 lg:px-10`), so the content is the full 944 px.

Prose on those pages is capped at `max-w-[65ch]`. Headings and diagrams can use the full width.

The byline footer follows the page's width. Game screens stay full width: no change.

## Comments
