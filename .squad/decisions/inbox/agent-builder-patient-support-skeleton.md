# Decision: Patient Support agent skeleton — Copilot Studio export tooling gap

**Date:** 2026-04-30  
**Role:** Agent-Builder  
**Phase:** 5  
**Vignettes affected:** V1 (Patient onboarding & in-context support), V2 (HCP prescribing & patient roster), V3 (FCS account 360)  
**Author:** Agent-Builder  
**For Scribe to merge into `.squad/decisions.md`**

---

## Decision

Patient Support agent landed as a skeleton (spec + system-prompt + avatar SVG + export placeholder). No Copilot Studio export bundle is committed.

## Why

`pac copilot export` requires:

1. A live Power Platform environment with the agent already published in Copilot Studio.
2. `pac` CLI authenticated to that environment.
3. The agent published and the Direct Line channel enabled.

None of these are available in the Copilot coding agent sandbox. The export cannot be produced at PR time.

## What was created instead

| File | Description |
|---|---|
| `agents/patient-support/spec.md` | Full Topic 8 §6.1 per-agent spec |
| `agents/patient-support/system-prompt.md` | All 6 H2 sections (Tier-1 lint-compliant), skeletal content |
| `agents/patient-support/avatar.svg` | Hand-authored geometric mark — chat-bubble + CGM waveform + spark |
| `agents/patient-support/export/README.md` | Placeholder documenting expected export bundle structure and publish runbook |

## Operator follow-up (post-publish)

After the agent is published in Copilot Studio against the target environment:

```powershell
pac copilot export --name "Continuum Patient Support" --output agents/patient-support/export/
```

Commit the resulting bundle to `agents/patient-support/export/`. Update `manifest.json` in the export folder with the agent ID written to `cch_IdAgentPatientSupport`.

See full runbook in `agents/patient-support/spec.md` §Direct Line channel setup and `agents/patient-support/export/README.md`.

## Alternatives considered

- **Hand-author YAML topic stubs** — rejected; Copilot Studio topic YAML schema is not publicly documented and hand-authored stubs could mislead the operator.
- **Skip the export folder entirely** — rejected; the placeholder README is more useful than silence and the export folder is referenced by the agent-builder house rules.
