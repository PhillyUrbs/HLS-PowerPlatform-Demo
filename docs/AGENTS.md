# AGENTS.md — docs/

**Owner role(s):** Scribe (primary) · all roles co-author own surface docs

## Scope

All operator-facing and audience-facing documentation — README, install / upgrade /
uninstall guides, architecture, governance recommendations, permissions, env vars,
telemetry, accessibility, localization, voice & tone, branding, demo script, and
planning artifacts under `_planning/`.

## House rules

- Markdown lint clean (markdownlint-cli2 in Tier-1).
- File-link convention from `.github/copilot-instructions.md` § fileLinkification —
  no backticks for file names; relative-path links with line anchors when applicable.
- Planning artifacts under `_planning/`; operator-facing docs at the top level.
- Cross-references rather than duplication — if a fact is stated in `permissions.md`,
  link to it from `architecture.md` rather than copying.
- Demo script (`demo-script.md`) is Scribe-authored; talk track in annotated bullets,
  never verbatim sentences (Topic 9 lock).
- Knowledge prose (`data/knowledge/*.md`) authored by Scribe but lives under `data/`
  not `docs/`.

## Skills to use

- `gh` for issue + PR cross-references in decision entries

## Hand-off rules

- Hand off to **Lead** when an architectural change requires `architecture.md`
  refactor.
- Hand off to **Tester** to verify any code-flow described in docs actually matches
  reality.
- Receive PRs from every other role updating their own surface's docs.

## Definition of done (per PR)

- [ ] markdownlint clean
- [ ] File-link convention followed
- [ ] No duplication of facts stated elsewhere
- [ ] `decisions.md` updated if doc represents a new locked decision
- [ ] Spelling pass (single-operator's responsibility — no automated spellcheck yet)
