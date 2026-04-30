# Project Context

- **Owner:** Philip Urban
- **Project:** HLS Power Platform Demo (Contoso Continuum Health, Medtech CGM)
- **Stack:** Power Platform (Pages, Code Apps, Power Automate, Copilot Studio) + Dataverse + M365 + PowerShell 7
- **Created:** 2026-04-29

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

## 2026-04-29 — Phase 0 → 1 transition

Phase 0 closed after 7 sittings (1–6 + 4g) over a single working day. 5 PRs merged through main-protection (Tier-1 green every time), 4 closure-trail issues opened+closed for slate completeness, 6 active first-PR-target issues opened for phases 1–5. Sandbox env `Continuum Demo (Dev)` provisioned at https://orgeeaa078f.crm.dynamics.com/ with the SP app reg `continuum-demo-dev-sp` registered as Dataverse Application User. See [.squad/decisions.md](../../decisions.md) Phase-0-close entry for full inventory.

**Operator-runbook-relevant lessons captured:**
- pac admin create-service-principal has no --whatif; ours is essential.
- Trial → Sandbox conversion via admin portal only (no CLI path).
- pwsh on Windows mangles UTF-8 § / box-drawing glyphs in source unless BOM present; consistently using ASCII in user-facing strings until Tier-1 wires UTF-8-with-BOM gating.
- StrictMode + empty PSCustomObject = Properties.Name throws; wrapped in Test-/Set-PSObjectProperty helpers in scripts/lib/Governance.ps1.
