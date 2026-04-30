# Patient Support agent — Copilot Studio export

**Status:** Export placeholder — Copilot Studio export tooling not available in the Copilot coding agent sandbox.

## What goes here

When the agent is published in Copilot Studio against the target environment, the export bundle should be placed here:

```
agents/patient-support/export/
  PatientSupportAgent.zip          # Raw Copilot Studio export (.zip)
  topics/
    PersonaRouter.yaml             # Persona-router topic
    PatientGreeting.yaml           # Greeting topic — Patient persona
    HCPGreeting.yaml               # Greeting topic — HCP persona
    FCSGreeting.yaml               # Greeting topic — FCS persona
    AnonymousGreeting.yaml         # Greeting topic — Anonymous persona
    PatientFallback.yaml           # Safe-fallback topic — Patient group
    HCPFallback.yaml               # Safe-fallback topic — HCP group
    FCSFallback.yaml               # Safe-fallback topic — FCS group
    AnonymousFallback.yaml         # Safe-fallback topic — Anonymous group
  manifest.json                    # Agent metadata (id, schemaVersion, topics[])
```

## Salutation templates in greeting topics

Topics must use these **verbatim** strings (Topic 8 §Voice & Tone lock):

| Topic file | Salutation |
|---|---|
| `PatientGreeting.yaml` | `"Hi {personaName} — I'm here to help with your CGM today."` |
| `HCPGreeting.yaml` | `"Dr. {personaName}, here are today's flagged items for your roster."` |
| `FCSGreeting.yaml` | `"Hey {personaName} — ready to find what you need."` |
| `AnonymousGreeting.yaml` | `"Hi — I'm the Continuum support assistant. What brings you in today?"` |

## How to export from Copilot Studio

1. Open the agent in Copilot Studio.
2. Go to **Settings → Export** (or use the CLI: `pac copilot export --name "Continuum Patient Support" --output agents/patient-support/export/`).
3. Commit the export bundle to this folder.
4. Update `manifest.json` with the agent ID written to `cch_IdAgentPatientSupport`.

## Persona-router topic structure

The persona-router topic should implement a condition branch on `{personaRole}`:

```
Trigger: Conversation Start
  ├── Condition: personaRole == "Patient"    → Redirect to PatientGreeting
  ├── Condition: personaRole == "HCP"        → Redirect to HCPGreeting
  ├── Condition: personaRole == "FCS"        → Redirect to FCSGreeting
  └── Else (Anonymous / missing)             → Redirect to AnonymousGreeting
```

## Gap tracking

This placeholder was created because the Copilot coding agent sandbox does not have:
- `pac copilot` CLI access to a live Power Platform environment
- Copilot Studio REST API credentials

The human operator should fill this folder after publishing the agent to the target environment.
See `.squad/decisions/inbox/agent-builder-patient-support-skeleton.md` for the full decision record.
