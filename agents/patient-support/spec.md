# Patient Support Agent — Specification

**Per Topic 8 §6.1 · Phase 5 · Agent-Builder**

---

## Identity

| Property | Value |
|---|---|
| **Agent name** | Continuum Patient Support |
| **Agent ID env var** | `cch_IdAgentPatientSupport` |
| **Direct Line secret env var** | `cch_SecretDirectLinePatientSupport` |
| **Avatar** | `agents/patient-support/avatar.svg` (brand teal `#0E7C86`) |
| **Copilot Studio environment** | Target environment set via `pac env select` at operator time |

### Direct Line channel setup (operator runbook)

1. Publish the agent in Copilot Studio.
2. Go to **Settings → Channels → Direct Line** and enable the channel.
3. Copy the **Secret key** (not the token).
4. Store the secret in Dataverse via the `Resolve-Secret` helper:
   ```powershell
   # In scripts/install.ps1 or interactively:
   # The "plain:" prefix is the project SecretRef format (Topic 4 lock).
   # Dataverse environment variable values are encrypted at rest by the platform.
   # Never commit the actual secret value; use .env.local for local development.
   Set-EnvironmentVariableValue -Name 'cch_SecretDirectLinePatientSupport' -Value "plain:<secret>"
   ```
5. Record the **Agent ID** (from the Copilot Studio URL, e.g. `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).
6. Store the agent ID:
   ```powershell
   Set-EnvironmentVariableValue -Name 'cch_IdAgentPatientSupport' -Value "<agentId>"
   ```

> **Note:** The Direct Line secret and agent ID are operator-time values. They are never committed to the repository. Use `.env.local` for local development only.

---

## Conversation variables

Declared at the top of every topic (set by host before first turn):

| Variable | Type | Set by | Description |
|---|---|---|---|
| `personaId` | `string` | Host (Code App / Pages) | Dataverse contact GUID or anonymous session GUID |
| `personaName` | `string` | Host | Display name (`FirstName` for Patient/FCS, `LastName` for HCP) |
| `personaRole` | `string` | Host | `Patient \| HCP \| FCS \| Anonymous` |
| `primaryAccountId` | `string?` | Host | Dataverse `cch_Account` GUID (FCS/HCP only) |
| `primaryPatientId` | `string?` | Host | Dataverse `cch_Patient` GUID (Patient / HCP topics) |
| `surface` | `string` | Host | `Pages \| CodeApp \| Teams` |
| `correlationId` | `string` | Host | Direct Line conversation ID (echoed on every tool call) |

---

## Topic hierarchy

```
[ROOT] Persona-Router
  ├── personaRole == 'Patient'    → group: Patient
  ├── personaRole == 'HCP'        → group: HCP
  ├── personaRole == 'FCS'        → group: FCS
  └── personaRole == 'Anonymous'  → group: Anonymous
```

### Patient group (V1)

| # | Topic | Type | Tool |
|---|---|---|---|
| 1 | Greeting + intent classification | Greeting | — |
| 2 | Troubleshoot sensor problem | Knowledge | SP `Patient/Troubleshooting/` |
| 3 | Request sensor replacement | Confirm-before-write | `RequestReplacement` |
| 4 | Check order/shipment status | Read | `GetMyShipmentStatus` |
| 5 | FAQ — How to apply the sensor | Knowledge | SP `Patient/ApplySensor/` |
| 6 | Schedule clinician callback | Confirm-before-write | `CreateCallbackRequest` |
| 7 | File a complaint | Confirm-before-write | `FileComplaint` |
| 8 | Fallback | Safe-fallback | `CreateCallbackRequest` (ticket row) |

### HCP group (V2)

| # | Topic | Type | Tool |
|---|---|---|---|
| 1 | Greeting + daily briefing | Greeting + Read | `GetHCPDailyBriefing` |
| 2 | Tell me about Patient X | Read | `SummarizePatient` |
| 3 | Roster query | Read | `QueryRoster` |
| 4 | Fallback | Safe-fallback | — |

### FCS group (V3)

| # | Topic | Type | Tool |
|---|---|---|---|
| 1 | Greeting + today's briefing | Greeting + Read | `GetFCSDailyBriefing` |
| 2 | Summarize an account | Read | `SummarizeAccount` |
| 3 | Draft Outlook email follow-up | Write (preview-only) | `DraftEmailPreview` |
| 4 | Post Teams channel update | Confirm-before-write | `PostTeamsChannelUpdate` |
| 5 | Answer training/product question | Knowledge | SP `Enablement/` |
| 6 | Order sample inventory | Confirm-before-write | `OrderSamples` |
| 7 | Submit complaint on behalf of account | Confirm-before-write | `FileComplaint` |
| 8 | Fallback | Safe-fallback | — |

### Anonymous group (V1 pre-registration)

| # | Topic | Type | Tool |
|---|---|---|---|
| 1 | Greeting + How can I help? | Greeting | — |
| 2 | About CGM / How it works | Knowledge | SP `Patient/AboutCGM/` |
| 3 | How to register | Link | — |
| 4 | Talk to a person | Confirm-before-write | `CreateCallbackRequest` |
| 5 | Fallback | Safe-fallback | — |

---

## Greeting salutation templates (locked — Topic 8 §Voice & Tone)

Do **not** paraphrase these strings:

| Persona | Salutation |
|---|---|
| Patient | `"Hi {personaName} — I'm here to help with your CGM today."` |
| HCP | `"Dr. {personaName}, here are today's flagged items for your roster."` |
| FCS | `"Hey {personaName} — ready to find what you need."` |
| Anonymous | `"Hi — I'm the Continuum support assistant. What brings you in today?"` |

---

## Tool inventory (12 tools — not wired in Phase 5.0)

> Tool wiring depends on Flows-Engineer Phase 4 flows (issue #8). Topics are stubbed; tool connections are added in subsequent PRs.

| Tool | Input args | Output `data` | Notes |
|---|---|---|---|
| `RequestReplacement` | `{patientId, deviceSerial, reason}` | `{caseId, shipmentId, etaDate}` | Confirm-before-write |
| `GetMyShipmentStatus` | `{patientId}` | `{shipments: [{id, status, eta}]}` | Read-only, silent |
| `CreateCallbackRequest` | `{patientId?, contactName?, contactEmail, topic}` | `{ticketId}` | Confirm-before-write |
| `FileComplaint` | `{patientId, deviceSerial, narrative}` | `{complaintId, mdrClockExpiresAt}` | Confirm-before-write; bridges to V4 |
| `GetHCPDailyBriefing` | `{hcpUserId}` | `{patientsNeedingAttention, refillsDue, recentComplaints, newRegistrations}` | Read-only |
| `SummarizePatient` | `{patientId}` | `{summary, recentReadings, riskFlags}` | Read-only |
| `QueryRoster` | `{hcpUserId, filters}` | `{patients: [...]}` | Read-only |
| `GetFCSDailyBriefing` | `{fcsUserId}` | `{plannedVisits, lowStockSkus, openCases, certsExpiring}` | Read-only |
| `SummarizeAccount` | `{accountId}` | `{summary, hcps, recentActivity, openCases}` | Read-only |
| `DraftEmailPreview` | `{accountId, intent, keyPoints[]}` | `{subject, body, recipients[]}` | Preview-only — no Outlook call |
| `PostTeamsChannelUpdate` | `{accountId, channelId, message}` | `{messageId, channelDeepLink}` | Confirm-before-write; SP via Graph |
| `OrderSamples` | `{accountId, hcpId, sku, qty}` | `{sampleOrderId}` | Confirm-before-write |

All tools use the standard envelope `{success, data, displayMessage, citations[], correlationId, errorCode?}` validated by `scripts/lib/AgentToolContract.schema.json`.

---

## Knowledge sources

| Source | Scope | Grounding method |
|---|---|---|
| SharePoint `Continuum Knowledge/Patient/` | Patient group | Direct knowledge grounding (agent reads as SP identity) |
| SharePoint `Continuum Knowledge/Enablement/` | FCS group (product/training Q&A) | Direct knowledge grounding |
| SharePoint `Continuum Knowledge/Shared/` | All groups | Direct knowledge grounding |
| Dataverse `cch_Patient` | Patient/HCP topics (own device/shipment history) | Via tool calls only |

> **Anonymous users never read SharePoint directly.** The agent reads as SP identity and surfaces answers via Direct Line (Topic 11 §C8 lock).

---

## Out of scope (separate PRs)

- Tool topic wiring (`RequestReplacement`, `FileComplaint`, etc.) — depends on issue #8 flows
- Knowledge grounding setup (SharePoint subfolder provisioning) — depends on `install.ps1`
- Direct Line channel publishing → `cch_SecretDirectLinePatientSupport` value capture — operator runbook step above
- Quality Triage agent + Continuum Enablement agent — separate Phase 5 issues
