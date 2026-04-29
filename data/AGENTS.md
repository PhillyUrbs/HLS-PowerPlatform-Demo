# AGENTS.md — data/

**Owner role(s):** Dataverse-Engineer (skeletons, fixtures) · Tester (test-data tagging) · Scribe (knowledge prose)

## Scope

Build-time-only assets that seed the demo: Faker-driven seed scripts (`seed.ts`),
date offsets (`offsets.ts`), demo-fill fixtures (`fixtures/demo-fills.ts`), the
user-populated `names/people.md`, and the 15 knowledge `.md` source documents
under `knowledge/<subfolder>/`.

## House rules

- Synthetic only. Faker locale fixed to `en_US` (Topic 7 lock).
- Names sourced from `names/people.md` (user-populated); never hard-coded in seed
  scripts.
- All time-sensitive fields use **offsets** from `offsets.ts`, never hard-coded
  dates. Seeds compute `now - offset` at runtime so data is evergreen.
- Knowledge `.md` docs use `{{today}}` and `{{current_quarter}}` template tokens —
  the templated-doc weekly republish flow substitutes at render time.
- Front-matter on every knowledge doc: `title`, `category`, `version`, `lastReviewed`,
  `owner` (synthetic).
- Fixture rows for E2E tests tagged `cch_TestRun = true` (Topic 6 + locked §3.17).
- Knowledge ACLs (Topic 8B): Read = SP + DemoOperator, Write = DemoOperator only,
  Anonymous = none. Enforced by `audit-permissions`.

## Skills to use

- `add-sample-data` for fixture seeding

## Hand-off rules

- Hand off to **Flows-Engineer** when the templated-doc republish flow needs new
  source files.
- Hand off to **Agent-Builder** when knowledge content needs alignment with a
  topic / utterance change.
- Receive **Scribe** PRs for knowledge prose content (Scribe owns prose; Dataverse-
  Engineer reviews structural drift from skeleton).

## Definition of done (per PR)

- [ ] Faker `en_US` locale used
- [ ] No hard-coded dates in seeds (use offsets)
- [ ] Knowledge .md front-matter complete and template tokens present
- [ ] `cch_TestRun` tagging on E2E fixtures
- [ ] doctor `[Knowledge]` section still passes (count, freshness)
