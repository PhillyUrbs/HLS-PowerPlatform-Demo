<!--
PR template per Topic 10 Squad charter (locked 2026-04-29).
- Branch name should match `feature/p<N>-<name>` (Tier-1 lints regex `^feature/p[0-6]-[a-z0-9-]+$`).
- PR title should follow Conventional Commits (Tier-1 lints).
- Squash-merge is the project default.
-->

## Summary

<!-- One paragraph: what changed and why. Link the issue if applicable: Fixes #N -->

## Affected role(s)

<!-- Check all that apply. See .squad/charter.md for role boundaries. -->

- [ ] Lead
- [ ] Dataverse-Engineer
- [ ] Pages-Engineer
- [ ] CodeApp-Engineer
- [ ] Flows-Engineer
- [ ] Agent-Builder
- [ ] Governance
- [ ] Tester
- [ ] Scribe

## Affected phase(s)

<!-- Tier-1 warns (does not block) if PR touches files in `warningFolders` for the current phase per .squad/phase.json. -->

- [ ] Phase 0 (Tenant & governance setup)
- [ ] Phase 1 (Data model & seed)
- [ ] Phase 2 (Power Pages Code Site)
- [ ] Phase 3 (Power Apps Code App)
- [ ] Phase 4 (Power Automate flows)
- [ ] Phase 5 (Copilot Studio agents)
- [ ] Phase 6 (Demo script & polish)
- [ ] Cross-cutting

## Decisions

- [ ] No new decisions
- [ ] New decision(s) added to `.squad/decisions.md` via the inbox pattern (`.squad/decisions/inbox/<role>-<slug>.md`); Scribe will merge.
      <!-- If adding a decision, paste the entry text below for reviewer context. -->

## Checks

<!-- Per Definition of Done in the relevant subfolder AGENTS.md. -->

- [ ] Tests added or extended where applicable
- [ ] Docs updated where applicable
- [ ] `audit-permissions` clean (if Pages-affecting — `sites/continuum-portal/**` or Pages YAML)
- [ ] a11y axe Tier-1 green (if React-affecting — `apps/**` or `sites/**`)
- [ ] `--whatif` default for any new state-changing PowerShell script
- [ ] No secrets committed (`.env.local` only; secrets in Dataverse env vars via `cch_ResolveSecret`)
- [ ] Branch name matches `feature/p<N>-<name>`

## Notes for reviewer

<!-- Anything reviewers should know: tradeoffs, open questions, follow-up issues. -->
