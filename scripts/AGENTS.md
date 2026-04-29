# AGENTS.md — scripts/

**Owner role(s):** Lead (primary) · Tester (doctor + smoke + Test-All)

## Scope

PowerShell 7 scripts for the demo lifecycle: install · upgrade · uninstall · doctor ·
seed · refresh-dates. Plus governance scripts under `governance/`, super-user
management (`Add-DemoUser.ps1` etc.), service principal setup, GitHub secrets helper,
and the shared `lib/` modules.

## House rules

- PowerShell 7 only.
- `--whatif` is the **default** for any state-changing operation; operator must pass
  `-Apply` to mutate. Locked Topic 5.
- Idempotent — safe to re-run. Never assume prior state.
- Use `Resolve-Secret` (Topic 4) for every secret value. Never inline secrets, never
  read raw env vars in flows.
- Cross-platform path handling (`Join-Path`, no backslash literals).
- Pester 5 for unit tests in `scripts/tests/`.
- Logs to `scripts/.last-run/<name>.log` (gitignored).
- Confirm-before-destructive: any `delete` / `remove` / `clean` operation prompts
  unless `-AcceptDestructive` flag is passed (locked AGENTS.md house rule).

## Skills to use

- `pac` family for solution import/export
- `gh` for issue / release operations (non-destructive)
- `az` for KV operations (build-time only; runtime independence locked Topic 4)

## Hand-off rules

- Hand off to **Governance** for `scripts/governance/*` content (Lead emits; Governance
  authors).
- Hand off to **Tester** for new doctor sections + new smoke checks.
- Hand off to **Dataverse-Engineer** for new migration declarations.

## Definition of done (per PR)

- [ ] Pester 5 unit tests pass (`scripts/tests/`)
- [ ] PSScriptAnalyzer Tier-1 green
- [ ] `--whatif` default for any new mutation
- [ ] doctor section updated if new mutation surface added
- [ ] `decisions.md` entry if architecture-affecting (new lifecycle mode, new flag)
