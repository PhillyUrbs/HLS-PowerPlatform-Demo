# Project Context

- **Project:** HLS-PowerPlatform-Demo
- **Created:** 2026-04-29

## Core Context

Agent Scribe initialized and ready for work.

## Recent Updates

📌 Team initialized on 2026-04-29
📌 Phase 0 closed; Phase 1 opens (2026-04-29) — see [.squad/decisions.md](../../decisions.md) for full inventory across 7 sittings + 5 merged PRs.
📌 Inbox-promotion run on 2026-04-30: 2 inbox entries (`agent-builder-patient-support-skeleton.md` + `flows-engineer-infrastructure-flows-pr1.md`) promoted into `.squad/decisions.md` Active Decisions. Inbox emptied. Inbox files were created by Copilot Cloud agents on PRs #23 + #24 in response to my review feedback (cross-cutting "decisions go in inbox, not directly into decisions.md" lesson — first time the pattern was followed by autonomous agents end-to-end).
📌 Inbox-promotion run #2 on 2026-04-30: codeapp-engineer-app-scaffold.md promoted (composite entry covering 3 cross-cutting decisions + the .gitignore-inbox-defect fix discovered while authoring this file). Inbox emptied. v0.3.0 + v0.4.0 + v0.5.0 tagged at their respective merge commits.

## Learnings

Initial setup complete.

## 2026-04-29 — Decisions log conventions

- The locked entry shape (`## YYYY-MM-DD — <Title>`) requires the em-dash glyph (—, U+2014). The Tier-1 lint regex tolerates it but author tooling (Git Bash heredocs, pwsh-Windows OEM read) sometimes mangles it. When dropping inbox entries, use the literal em-dash, not a hyphen-minus.
- Phase-transition entries are dense (full sitting inventory + env state + what-not-yet-done + alternatives + references). They're the operator's and future-Squad's primary onboarding doc per phase, so worth the depth.

## 2026-04-30 — Inbox-promotion mechanics

- Inbox files use any heading shape the author wants; promotion rewrites them into the locked decisions.md `## YYYY-MM-DD — <Title>` shape with strict Decided / Why / Alternatives / Affects sections.
- Each inbox file may carry **multiple decisions** (PR #23's flows-engineer file had 3). Promotion can either (a) merge into one composite decision entry or (b) split into N entries. Composite is appropriate when the decisions share a single PR and theme; split when they cross unrelated subjects. PR #23 was merged as one composite (3-precedent entry); PR #24 was a single decision so 1:1.
- Always add a `**References:**` line citing the PR + merge SHA + GitHub issue number. This makes Phase-N closeouts and audit trails trivial.
- Append-only on decisions.md; reverse-chronological inserts go directly under `## Active Decisions` so newest-first is preserved.
