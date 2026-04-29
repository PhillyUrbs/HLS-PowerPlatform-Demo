# Topic 8 — Per-agent topic & tool design (locked)

**Locked on:** 2026-04-29
**Scenario layer:** 🟡 **Hybrid** — *Structure agnostic* (standard tool envelope `{success, data, displayMessage, citations[], correlationId, errorCode?}`, 10 standard error codes, `cch_AgentToolWrapper` child flow, persona-router topic + per-persona-group pattern, autonomous-trigger wrapper flow pattern, M365 readiness checklist, `<AgentChatHost/>` 3-size variants, `<CitationsRenderer/>` 4 modes, no-live-handoff inter-agent pattern, per-conversation memory model, freshness-no-disclaimer pattern, 6-section system-prompt template, 5 Adaptive Card templates incl. persona-in-header partial). *Content scenario-specific* (3 agent identities, 18 tool flows, persona-aware salutation templates, knowledge-source layout, voice & tone per agent, safe-fallback wording). Forking: keep all framework patterns; rewrite the agent roster + tool inventory + voice + knowledge.

## Framing

- Locked **agent lineup** in handoff §6: Patient Support (V1/V2/V3 persona-aware), Quality Triage (V4 autonomous), Continuum Enablement (V5 + V6).
- Locked **tool capabilities** at coarse level in §6.1, §6.2, §6.3.
- Locked **connection ownership** in §3.7: SP via Graph by default, interactive identity for personal-mailbox/calendar/Teams-1:1/OneDrive-personal.
- Locked **persona-in-header pattern** for Teams Adaptive Cards (§3.7) — drives card design across V3/V4/V5/V6.
- Locked **Phase-0 discipline**: every flow uses Connection References + Environment Variables.
- Topic 4 added Direct Line secret env vars (`cch_SecretDirectLine*`) and `cch_IssueDirectLineToken` flow.
- Topic 6 added telemetry mirror "only what CS analytics misses" with `cch_LogTelemetry` child flow.

## Decisions

| Area | Decision |
|---|---|
| **Spec format** | Per-agent `spec.md` co-located with the export at `agents/<name>/spec.md` |
| **Tool contract** | Standard envelope `{success, data, displayMessage, citations[], correlationId}` (JSON Schema validated by Tier-1) |
| **Knowledge layout** | One SharePoint library `Continuum Knowledge` with subfolders `Patient/`, `Quality/`, `Enablement/`, `Shared/`. Agents scope to own folder + `Shared/`. **Plus Dataverse-as-knowledge** for Quality (complaint/lot history) and Patient (own device/shipment history). **No public-web grounding** (intentionally out of scope) |
| **Patient Support topic organization** | Persona-router topic + per-persona topic groups (Patient / HCP / FCS), each topic gates on `personaRole` |
| **Quality Triage trigger** | Wrapper flow `cch_TriggerQualityTriage` with idempotency check + retry + error handling; agent stays clean |
| **Per-tool telemetry** | Wrapper child flow `cch_AgentToolWrapper` standardizes `toolcall.<name>.started/.completed/.failed` logging |
| **M365 readiness** | Explicit 6-item checklist at `agents/employee-enablement/m365-readiness.md`; doctor verifies file exists + checks all 6 boxes |

## Voice & tone (per agent)

| Agent | Voice | Tone | Reading level | Emoji |
|---|---|---|---|---|
| **Patient Support** | warm, plain-language, reassuring; uses "we" (the Continuum team) more than "I" | reassuring, never alarmist; clinical jargon always parenthetical-explained | ~7th grade | rare, only for confirmations (✓) |
| **Quality Triage** | precise, clinical, citation-led; declarative not chatty; never "I think" — always "evidence suggests" / "classification: <choice>" | analytical | ~14th grade (clinical) | none |
| **Continuum Enablement** | upbeat, expert-peer, action-oriented; treats user as colleague; cites sources by name | conversational | ~12th grade | light, on confirmations only (✓ 🎯) |

### Cross-cutting patterns (all 3 agents)

- **Persona-aware salutation on first turn.** Templated:
  - Patient: `"Hi <FirstName> — I'm here to help with your CGM today."`
  - HCP: `"Dr. <LastName>, here are today's flagged items for your roster."`
  - FCS: `"Hey <FirstName> — ready to find what you need."`
  - Quality Analyst (V4): `"<FirstName>, complaint <ID> is ready for review."`
  - Anonymous (Patient Support only): `"Hi — I'm the Continuum support assistant. What brings you in today?"`
- **Safe-fallback:** never bare "I don't know". Always: empathic acknowledgement + route to human + create a row (support ticket / escalation case) so the gap is captured.
- **Confirm-before-write:** every write tool (replacement, sample order, training schedule, MDR file, escalate) presents a one-line confirmation (`displayMessage`) before invocation; user confirms inline. Read-only tools fire silently.

## Standard tool envelope

JSON Schema at `scripts/lib/AgentToolContract.schema.json`. Every tool flow input + output validated.

```json
// Input shape (per-tool input fields go in `args`)
{
  "args": { /* tool-specific */ },
  "context": {
    "personaId": "string",
    "personaRole": "Patient | HCP | FCS | QualityAnalyst | Anonymous",
    "primaryAccountId": "string?",
    "primaryPatientId": "string?",
    "correlationId": "string"   // Direct Line conversation id
  }
}
```

```json
// Output envelope
{
  "success": true,
  "data": { /* tool-specific */ },
  "displayMessage": "string",   // agent renders inline
  "citations": [
    { "title": "string", "url": "string", "excerpt": "string?" }
  ],
  "correlationId": "string",    // echoed for telemetry join
  "errorCode": "string?",
  "errorMessage": "string?"
}
```

- Tier-1 schema-drift validator (extension of Topic 6's payload validator) checks every tool flow's input/output bindings against this schema.
- `displayMessage` is the only required user-facing field; `citations` may be empty; `data` may be empty for fire-and-forget tools.

## Per-agent specs

### 6.1 Patient Support agent

**Identity:** `agents/patient-support/spec.md`. Avatar SVG (Topic 2). Direct Line secret `cch_SecretDirectLinePatientSupport`.

**Conversation variables (read at every turn):**
- `personaId, personaName, personaRole, primaryAccountId, primaryPatientId`
- `surface` — `Pages | CodeApp | Teams` (set by host)
- `correlationId` — Direct Line conversation id

**Topic hierarchy (persona-router + per-persona groups):**

```
[ROOT] Persona-Router
  ├── personaRole == 'Patient'   → group: Patient
  ├── personaRole == 'HCP'       → group: HCP
  ├── personaRole == 'FCS'       → group: FCS
  └── personaRole == 'Anonymous' → group: Anonymous
```

**Patient group topics (V1):**
1. **Greeting + intent classification** — salutation + 4 prompt-starter chips
2. **Troubleshoot sensor problem** — knowledge-grounded (SP `Patient/Troubleshooting/`); no tool call
3. **Request sensor replacement** — confirm-before-write → `tool:RequestReplacement` → animated dashboard card
4. **Check order/shipment status** — `tool:GetMyShipmentStatus` (read)
5. **FAQ — How to apply the sensor** — knowledge-grounded; no tool
6. **Schedule clinician callback** — confirm-before-write → `tool:CreateCallbackRequest`
7. **File a complaint** — confirm-before-write → `tool:FileComplaint` (bridges to V4)
8. **Fallback** — safe-fallback pattern (creates support-ticket row)

**HCP group topics (V2):**
1. **Greeting + daily briefing** — `tool:GetHCPDailyBriefing` (read) → renders summary
2. **Tell me about Patient X** — `tool:SummarizePatient` (read; reuses Patient knowledge)
3. **Roster query** — `tool:QueryRoster` (read; FetchXML over `cch_Patient` filtered by `PrimaryHCP`)
4. (other HCP topics surface as deep-links to roster filters; no separate topic needed)
5. **Fallback** — safe-fallback pattern

**FCS group topics (V3):**
1. **Greeting + today's briefing** — `tool:GetFCSDailyBriefing` (read)
2. **Summarize an account** — `tool:SummarizeAccount` (read)
3. **Draft Outlook email follow-up** — `tool:DraftEmailPreview` (write — preview-only, locked V3 decision)
4. **Post Teams channel update** — confirm-before-write → `tool:PostTeamsChannelUpdate` (real channel post via SP+Graph)
5. **Answer training/product question** — knowledge-grounded (SP `Enablement/`)
6. **Order sample inventory** — confirm-before-write → `tool:OrderSamples`
7. **Submit complaint on behalf of account** — confirm-before-write → `tool:FileComplaint` (shared with Patient group)
8. **Fallback**

**Anonymous group topics (V1 pre-registration):**
1. **Greeting + How can I help?** — surfaces 4 chips (About CGM, How to register, FAQ, Talk to a person)
2. **About CGM / How it works** — knowledge-grounded
3. **How to register** — links to registration form (no tool)
4. **Talk to a person** — `tool:CreateCallbackRequest`
5. **Fallback**

**Tool inventory (10 tools):**

| Tool | Input args | Output `data` | Connection owner |
|---|---|---|---|
| `RequestReplacement` | `{patientId, deviceSerial, reason}` | `{caseId, shipmentId, etaDate}` | SP (Dataverse) |
| `GetMyShipmentStatus` | `{patientId}` | `{shipments: [{id, status, eta}]}` | SP (Dataverse) |
| `CreateCallbackRequest` | `{patientId?, contactName?, contactEmail, topic}` | `{ticketId}` | SP (Dataverse) |
| `FileComplaint` | `{patientId, deviceSerial, narrative}` | `{complaintId, mdrClockExpiresAt}` | SP (Dataverse) |
| `GetHCPDailyBriefing` | `{hcpUserId}` | `{patientsNeedingAttention, refillsDue, recentComplaints, newRegistrations}` | SP (Dataverse) |
| `SummarizePatient` | `{patientId}` | `{summary, recentReadings, riskFlags}` | SP (Dataverse) |
| `QueryRoster` | `{hcpUserId, filters}` | `{patients: [...]}` | SP (Dataverse) |
| `GetFCSDailyBriefing` | `{fcsUserId}` | `{plannedVisits, lowStockSkus, openCases, certsExpiring}` | SP (Dataverse) |
| `SummarizeAccount` | `{accountId}` | `{summary, hcps, recentActivity, openCases}` | SP (Dataverse) |
| `DraftEmailPreview` | `{accountId, intent, keyPoints[]}` | `{subject, body, recipients[]}` *(preview only — no send)* | SP (Dataverse for context lookup); no Outlook call |
| `PostTeamsChannelUpdate` | `{accountId, channelId, message}` | `{messageId, channelDeepLink}` | SP via Graph (persona-in-header card) |
| `OrderSamples` | `{accountId, hcpId, sku, qty}` | `{sampleOrderId}` | SP (Dataverse) + SP via Graph (Teams card) |

### 6.2 Quality Triage agent

**Identity:** `agents/quality-analyst/spec.md`. Avatar SVG (Topic 2). Direct Line secret `cch_SecretDirectLineQualityTriage`. Used in V4 only.

**Trigger contract:**

`cch_TriggerQualityTriage` flow (Dataverse row-create on `cch_Complaint`):

1. **Idempotency check** — exit if `cch_AgentStatus` ∈ {`Triaging`, `Triaged`, `Drafting`, `Drafted`, `AwaitingReview`}.
2. **Telemetry checkpoint** — `cch_LogTelemetry({eventName: 'quality.triage.triggered', correlationId: <complaintId>})`.
3. **Set status** — `cch_AgentStatus = Triaging`.
4. **Invoke agent** — POST to Direct Line with `{complaintId, narrative, deviceLot, patientId}` and `correlationId`.
5. **Retry-on-failure** — exponential backoff, max 3 attempts; on final failure set `cch_AgentStatus = Failed` + post error Adaptive Card to `cch_IdTeamsChannelQuality`.
6. **Done** — agent's tool calls drive the rest (write triage fields, write MDR draft, post triage card).

**Conversation variables:**
- `complaintId, deviceLot, patientId, surface ('Triggered' | 'AnalystChat'), correlationId`
- `analystPersonaId` (set when surface = `AnalystChat`)

**Topic hierarchy:**

- **Triggered (autonomous) flow:**
  1. `OnComplaintTriaged` — entry topic for trigger
  2. **Read context** — `tool:ReadComplaintContext` (read)
  3. **Read related complaints** — `tool:GetRelatedComplaints` (read)
  4. **Triage** — internal LLM reasoning + `tool:WriteTriageFields` (writes classification, severity, confidence, rationale, citations, MDR-reportable, MDR-clock)
  5. **Draft MDR if reportable** — `tool:WriteMdrDraft`
  6. **Post Teams card** — `tool:PostQualityTriageCard`
  7. **Set `cch_AgentStatus = AwaitingReview`**

- **Analyst-chat (docked panel) topics:**
  1. **Why MDR-reportable?** — answers from `cch_AgentRationale` + `cch_AgentCitations`
  2. **Show me other complaints on this lot** — `tool:GetRelatedComplaints` (filtered by lot)
  3. **Re-run triage with this added context** — `tool:WriteTriageFields` (re-triage with operator-supplied note)
  4. **Summarize this case for me** — `tool:SummarizeComplaint`
  5. **Escalate** — confirm-before-write → `tool:EscalateComplaint` (posts second Adaptive Card to `cch_IdTeamsChannelLeadership`)
  6. **Fallback**

**Tool inventory (8 tools):**

| Tool | Input args | Output `data` | Connection owner |
|---|---|---|---|
| `ReadComplaintContext` | `{complaintId}` | `{complaint, patient, device, lot, deviceHistory}` | SP (Dataverse) |
| `GetRelatedComplaints` | `{patientId?, lot?, narrativeKeywords?}` | `{complaints: [...], lotPattern: {...}}` | SP (Dataverse) |
| `WriteTriageFields` | `{complaintId, classification, severity, confidence, rationale, citations[], mdrReportable}` | `{updatedAt}` | SP (Dataverse) |
| `WriteMdrDraft` | `{complaintId, draftMarkdown}` | `{updatedAt}` | SP (Dataverse) |
| `PostQualityTriageCard` | `{complaintId, severity, classification, confidence, mdrClockExpiresAt}` | `{messageId, channelDeepLink}` | SP via Graph (persona-in-header) |
| `SummarizeComplaint` | `{complaintId}` | `{summaryMarkdown}` | SP (Dataverse) |
| `EscalateComplaint` | `{complaintId, reason}` | `{messageId}` | SP via Graph (leadership channel) |
| `RequeryRelatedComplaints` | `{complaintId, additionalContext}` | `{complaints: [...]}` *(invoked by analyst chat re-triage)* | SP (Dataverse) |

### 6.3 Continuum Enablement agent

**Identity:** `agents/employee-enablement/spec.md`. Avatar SVG. Direct Line secret `cch_SecretDirectLineEnablement`. Multi-surface (Code App / Teams 1:1 / SharePoint webpart / M365 Copilot).

**Conversation variables:**
- `personaId, personaName, personaRole` (set by Code App; M365/Teams use real signed-in user — narration handles the difference per locked V6 decision)
- `surface` — `CodeApp | Teams | SharePoint | M365Copilot`
- `correlationId`

**Knowledge sources:**
- SharePoint `Enablement/Manuals/` (Continuum CGM G7, G7 Pro, accessories)
- SharePoint `Enablement/Competitive/` (Contoso vs. Adventurer Glucose Inc.)
- SharePoint `Enablement/Policies/` (sample handling, expense, training mandates)
- SharePoint `Shared/RegulatoryGlossary/` + `Shared/MdrTemplate/`
- SharePoint `Enablement/Training/` + `Enablement/FAQs/`

**Topic hierarchy (flat — single persona):**

1. **Greeting** — surfaces 6 prompt-starter chips (locked Topic 1: V5 layout)
2. **What's new in <product>?** — knowledge-grounded; cites manuals + FAQs
3. **<X> vs Adventurer Glucose** — knowledge-grounded; cites competitive briefs
4. **Sample handling SOP** — knowledge-grounded
5. **Order samples** — confirm-before-write → `tool:OrderSamples` (shared flow with Patient Support FCS group)
6. **Schedule training** — confirm-before-write → `tool:ScheduleTraining`
7. **Look up regulatory clock** — knowledge-grounded (regulatory glossary)
8. **Look up internal policy** — knowledge-grounded
9. **Summarize an account** — `tool:SummarizeAccount` (shared flow)
10. **MDR clock for critical complaint** — knowledge-grounded; explains MDR template
11. **Fallback**

**Tool inventory (5 tools — 3 unique + 2 shared):**

| Tool | Input args | Output `data` | Connection owner |
|---|---|---|---|
| `OrderSamples` *(shared with Patient Support FCS)* | `{accountId, hcpId, sku, qty}` | `{sampleOrderId}` | SP (Dataverse) + SP via Graph (Teams card to `cch_IdTeamsChannelEnablement`) |
| `ScheduleTraining` | `{hcpId, productSku, preferredDate?}` | `{trainingRecordId, scheduledDate}` | SP (Dataverse) + SP via Graph (Teams card) |
| `LookupRegulatoryClock` | `{topicKey}` | `{summary, citations[]}` *(knowledge-only; no DV write)* | none (knowledge action) |
| `LookupInternalPolicy` | `{policyKey}` | `{summary, citations[]}` *(knowledge-only)* | none (knowledge action) |
| `SummarizeAccount` *(shared with Patient Support FCS)* | `{accountId}` | `{summary, hcps, recentActivity, openCases}` | SP (Dataverse) |

### Tool sharing & flow inventory

Total **distinct tool flows: 18** (Patient Support contributes 12, Quality Triage 8, Enablement reuses 2 — `OrderSamples` and `SummarizeAccount`):

```
Shared (called by 2 agents): OrderSamples, SummarizeAccount
Patient Support only (10): RequestReplacement, GetMyShipmentStatus, CreateCallbackRequest,
                           FileComplaint, GetHCPDailyBriefing, SummarizePatient, QueryRoster,
                           GetFCSDailyBriefing, DraftEmailPreview, PostTeamsChannelUpdate
Quality Triage only (8):   ReadComplaintContext, GetRelatedComplaints, WriteTriageFields,
                           WriteMdrDraft, PostQualityTriageCard, SummarizeComplaint,
                           EscalateComplaint, RequeryRelatedComplaints
Enablement only (3):       ScheduleTraining, LookupRegulatoryClock, LookupInternalPolicy

Plus infrastructure flows (locked Topics 4 + 6):
  cch_ResolveSecret (child)
  cch_IssueDirectLineToken
  cch_LogTelemetry (child)
  cch_AgentToolWrapper (child) — NEW this topic
  cch_TriggerQualityTriage — NEW this topic
```

Total **flows in solution: 18 tool flows + 5 infrastructure = 23** (before live-sim, refresh, vignette-reset, and shipment-stepper flows from earlier topics).

## `cch_AgentToolWrapper` child flow contract

Every tool flow's first action **invokes** `cch_AgentToolWrapper` with `(toolName, args, context)`; wrapper logs telemetry start, runs the tool body via callback (or post-action hook), logs completion/failure, returns the standard envelope.

```
INPUT:  toolName, args (object), context (object)
ACTION: 1. cch_LogTelemetry({eventName: 'toolcall.<toolName>.started', correlationId, payload: {args (redacted)}})
        2. (parent flow runs tool body)
        3. cch_LogTelemetry({eventName: 'toolcall.<toolName>.completed' | '.failed', latencyMs, correlationId})
OUTPUT: standard envelope (echoed back, with correlationId set if missing)
```

Implementation note: Power Automate child-flow conventions can't fully wrap parent logic, so the actual pattern is **two child-flow calls per tool** (start + finish) — wrapper exposes `LogStart` and `LogFinish` as separate operations under one solution flow.

## M365 readiness checklist (Enablement agent)

`agents/employee-enablement/m365-readiness.md` template:

```markdown
# M365 Copilot Readiness — Continuum Enablement Agent

- [ ] Description ≤ 200 chars set
- [ ] Conversation starters: 3+ defined and tested
- [ ] Icon assets: 32x32 PNG + 192x192 PNG committed
- [ ] Security review:
  - [ ] DLP scope verified (Topic 5 Business bucket)
  - [ ] Knowledge sources audited (SharePoint subfolders + permissions)
  - [ ] Action consent flow tested for OrderSamples + ScheduleTraining
- [ ] Localization confirmed: en-US only (Topic 7)
- [ ] M365 admin publish step run (operator one-time): see install.md § V6
```

Doctor's M365 readiness check:
```
[Agents]
- m365-readiness.md exists                      [pass | warn]
- All 6 checklist boxes checked                 [pass | warn: N unchecked]
- agents/employee-enablement/icons/ present     [pass | warn]
```

## Updates to earlier locked decisions

- **Handoff §6** — confirmed; this topic is the *contract* of record. No conflicts.
- **Handoff §3.11 repo layout** — adds:
  - `agents/<name>/spec.md` × 3
  - `agents/employee-enablement/m365-readiness.md`
  - `agents/employee-enablement/icons/` (32x32 + 192x192 PNGs)
  - `scripts/lib/AgentToolContract.schema.json`
  - Flows `cch_AgentToolWrapper` and `cch_TriggerQualityTriage` in solution
- **Topic 6 telemetry** — `cch_AgentToolWrapper` operationalizes the agent-event mirroring; payload schema gains tool-call subschema.
- **Topic 4 env vars** — already covers Direct Line secrets, agent IDs, Teams channel IDs. No new env vars from this topic.
- **Topic 3 permissions** — confirms `ServicePrincipal` role's table-write list must include `cch_Complaint`, `cch_ServiceCase`, `cch_Shipment`, `cch_SampleOrder`, `cch_TrainingRecord`, `cch_Patient` (read), `cch_Account` (read), `cch_HCP` (read), `cch_Device` (read).
- **Handoff §3.16 Tier 1** — gains tool-envelope schema-drift validator (extension of Topic 6 validator).
- **Knowledge layout** — locked SharePoint structure; install.ps1 provisions the library + subfolders + ACLs.

## Deliverables to commit

1. **`docs/_planning/topic-08-agents.md`** ← this file
2. **`agents/patient-support/spec.md`** — full spec per the structure above
3. **`agents/quality-analyst/spec.md`** — full spec
4. **`agents/employee-enablement/spec.md`** — full spec
5. **`scripts/lib/AgentToolContract.schema.json`** — input + output JSON Schema for the standard envelope
6. **`agents/employee-enablement/m365-readiness.md`** — checklist template
7. **Flow contracts** for `cch_AgentToolWrapper` + `cch_TriggerQualityTriage` documented in this topic doc; authored in Phase 4

## Intentionally out of scope (explicit)

- **Public-web grounding source** for Enablement agent (FDA URL set) — not picked. Avoids HTTP-with-Entra grounding-source maintenance + adds a new failure mode for live demos.
- **Three separate Patient Support agents** (one per persona) — explicitly rejected; one agent identity is the locked story.
- **Microsoft Graph (mailbox/OneDrive personal) as grounding** — violates persona-overlay model.

## Open follow-ups (deferred — not blocking)

- **Per-tool input/output schema** beyond the envelope — emerges during Phase 5 authoring; spec'd against `AgentToolContract.schema.json`.
- **Per-topic utterance examples** (training utterances) — Phase 5 work.
- **Adaptive Card layouts** for `PostQualityTriageCard`, `PostTeamsChannelUpdate`, sample-order/training-schedule confirmations — Phase 4 work; Topic 1 already locked the persona-in-header pattern + severity-color border.
- **Connector-to-tool cross-reference table** in `docs/connectors.md` — explicitly not picked as deliverable here; can fold in at Phase 4 connector audit.
- **Voice & tone short-doc** (Topic 2 deliverable) — gains the per-agent refinements above as its content.

---

# Topic 8B — Knowledge & prompt-starters (locked)

**Locked on:** 2026-04-29 (addendum to Topic 8 closing the scaffolding-shaped gaps)

## Knowledge document inventory (15 docs, minimum viable)

Source markdown lives at `data/knowledge/<subfolder>/<doc>.md`. The templated-doc weekly republish flow (locked §3.9) renders to `.docx` + `.pdf` and uploads to the matching SharePoint subfolder. All synthetic.

### `data/knowledge/Patient/` (3 docs)

| File | Purpose | Used by |
|---|---|---|
| `sensor-troubleshooting-guide.md` | Step-by-step troubleshooting flowchart for the 8 most common sensor issues | Patient agent V1 topic 2 (Troubleshoot) |
| `sensor-application-guide.md` | How to apply, calibrate, and remove the sensor | Patient agent V1 topic 5 (FAQ) |
| `patient-faq.md` | 12 grouped Q&As (signal loss, water exposure, alerts, calibration, replacement) | Patient agent V1 fallback grounding + Anonymous topic 2 |

### `data/knowledge/Quality/` (2 docs)

| File | Purpose | Used by |
|---|---|---|
| `complaint-classification-taxonomy.md` | Choice-value definitions: Adverse / Malfunction / DeviceFailure / UserError / Other with examples | Quality Triage triggered topic 4 (Triage) |
| `lot-quality-reference.md` | Lot-pattern detection thresholds, interpretation guidance | Quality Triage triggered topic 4 + analyst chat topic "Show me other complaints on this lot" |

### `data/knowledge/Enablement/` (7 docs)

| File | Purpose | Used by |
|---|---|---|
| `continuum-cgm-g7-manual.md` | Product manual for Continuum CGM G7 (specs, indications, contraindications, accessories) | Enablement topic 2 ("What's new in <product>") |
| `continuum-cgm-g7-pro-manual.md` | Product manual for the Pro variant | Enablement topic 2 |
| `sensor-accessories-catalog.md` | Adhesive overlays, transmitter cradles, charging accessories, SKUs | Enablement topic 5 (Order samples) |
| `competitive-brief-adventurer-glucose.md` | Side-by-side comparison: Continuum vs. fictional Adventurer Glucose Inc. | Enablement topic 3 (Competitive) |
| `sample-handling-sop.md` | SOP for receiving, storing, dispensing, returning samples | Enablement topic 4 (Sample SOP) |
| `expense-policy.md` | Per-diem, mileage, sample-budget policy | Enablement topic 8 (Lookup internal policy) |
| `training-catalog.md` | Available training modules + cadence + cert validity | Enablement topic 6 (Schedule training) |

### `data/knowledge/Shared/` (3 docs)

| File | Purpose | Used by |
|---|---|---|
| `regulatory-glossary.md` | Glossary: MDR, MDR-reportable, 21 CFR 803, ISO 13485 (high-level only — no FDA validation claims per locked §3.1) | Quality + Enablement |
| `mdr-template.md` | Template the Quality Triage agent uses to draft `cch_MdrDraft` | Quality Triage triggered topic 5 (Draft MDR) |
| `microsoft-fictitious-disclaimer.md` | Canonical footer wording (locked Topic 2 deliverable) | UI footer + every grounding doc footer |

### Authoring conventions
- Markdown supports the locked `{{today}}` and `{{current_quarter}}` templating tokens (handoff §3.9). Templated-doc flow substitutes these on every weekly render.
- Each doc front-matter declares: `title`, `category`, `version`, `lastReviewed` (renders to `{{today}}` on republish), `owner: Continuum Continuing Education Committee` (synthetic).
- Each rendered doc footer includes the Microsoft-fictitious-disclaimer (locked Topic 2).

## Knowledge subfolder ACLs

| Subfolder | Read | Write | Anonymous |
|---|---|---|---|
| `Patient/` | SP + DemoOperator | DemoOperator only | none |
| `Quality/` | SP + DemoOperator | DemoOperator only | none |
| `Enablement/` | SP + DemoOperator | DemoOperator only | none |
| `Shared/` | SP + DemoOperator | DemoOperator only | none |

- Templated-doc weekly republish flow runs as a **DemoOperator-bound** connection reference so it can write rendered `.docx` / `.pdf` artifacts back.
- `audit-permissions` Tier-1 check (locked Topic 3) extends to verify these ACLs match the spec; drift surfaces as a warning.
- Anonymous never reads from this library (matches locked Topic 3 AnonymousPatient web role).

## Prompt-starter chip text (5 surfaces)

The `<PromptStarter/>` component renders a row of 3–6 chips. Click populates the chat input (V5 has optional auto-send per locked spec). Pinned text below; copy belongs to the React component or to the welcome-card payload.

### V1 — Pages floating bubble, **Patient persona** (4 chips)
1. `How do I apply my sensor?`
2. `Check my latest order`
3. `Report a problem`
4. `Talk to my care team`

### V1 — Pages floating bubble, **Anonymous** (3 chips)
1. `How does CGM work?`
2. `How do I register?`
3. `I have a question`

### V2 — Pages dashboard panel, **HCP persona** (4 chips)
1. `Patients needing attention today`
2. `Tell me about Patient Sullivan`  *(persona-aware: substitutes top patient in caller's roster; Sullivan is the hero patient in seed data)*
3. `Refills due this week`
4. `New complaints on my roster`

### V3 — Code App docked panel, **FCS persona** (5 chips)
1. `Summarize this account`  *(uses currently-active account context)*
2. `Draft an email follow-up`
3. `Post a Teams update`
4. `Order samples for Dr. Hancock`  *(persona-aware: substitutes top HCP at active account; Hancock is the hero HCP in seed data)*
5. `Submit a complaint for this account`

### V5 — Code App Knowledge tab, **FCS / Quality** (6 chips, locked from handoff §7 V5)
1. `What's new in G7 Pro?`
2. `Adventurer comparison`
3. `Sample handling SOP`
4. `Order box-of-30 G7s for Dr. Hancock`
5. `Schedule G7 Pro training`
6. `MDR clock for critical complaint`

### V6 — Teams 1:1 welcome card (3 chips)
A subset of V5 surfaced via Adaptive Card welcome message:
1. `What's new in G7 Pro?`
2. `Order box-of-30 G7s for Dr. Hancock`
3. `Schedule G7 Pro training`

### Conventions
- Persona-aware substitutions (`Hancock`, `Patient Sullivan`) resolve at render time from the persona overlay store. Never hardcoded; falls back to a generic name (`Dr. Smith`) if no roster context.
- Chip text is sentence case, no terminal punctuation, ≤ 50 chars.
- Chips are **not** translated (en-US only per Topic 7).
- The `<PromptStarter/>` component reads chip definitions from a per-surface const file (`apps/.../config/promptStarters.ts`) so they can be tweaked without component changes.

## Doctor `Knowledge` section spec

```
[Knowledge]
- SP library `Continuum Knowledge` exists?            [pass | warn]
- Subfolders Patient/ Quality/ Enablement/ Shared/?   [pass | warn: missing N]
- Doc count per subfolder matches inventory?          [pass | warn: count mismatch]
- All 15 docs have rendered .docx + .pdf siblings?    [pass | warn: N missing]
- Oldest rendered doc age (templated-doc flow lag)    [pass: < 8d | warn: 8-14d | error: > 14d]
- ACLs match spec (DemoOperator write, SP read)       [pass | warn: drift detected]
- Prompt-starter config files present in apps/?       [pass | warn: missing for surface X]
```

All info/warning only (locked doctor read-only rule).

## Updates to earlier locked decisions

- **Topic 3 permissions** — gains the knowledge-library ACL spec table; `audit-permissions` Tier-1 check extends to verify.
- **Topic 6 telemetry** — no change (knowledge ground-truth events ride the existing `AgentEvent` category).
- **Handoff §3.11 repo layout** — adds:
  - `data/knowledge/Patient/` (3 .md files)
  - `data/knowledge/Quality/` (2 .md files)
  - `data/knowledge/Enablement/` (7 .md files)
  - `data/knowledge/Shared/` (3 .md files)
  - `apps/field-companion/src/config/promptStarters.ts`
  - `sites/continuum-portal/src/config/promptStarters.ts`
- **Templated-doc weekly republish flow** (locked §3.9) — gains a concrete source-document inventory of 15 .md files (was previously just a pattern).

## Topic 8B deliverables

1. **Append this section to `docs/_planning/topic-08-agents.md`** ✅ done
2. **`data/knowledge/<subfolder>/<doc>.md` skeletons** — 15 files with front-matter + minimum-viable section headings; full content authored in Phase 1 alongside data seed
3. **Chip text inventory** above lives in this topic doc; React `promptStarters.ts` is built from it in Phase 2/3
4. **Knowledge ACL spec** added to `docs/permissions.md` at deliverable time (Phase 1)
5. **Doctor `Knowledge` section spec** above implemented in `doctor.ps1` (Phase 0 work item updated)

---

# Topic 8C — Prompt structure, errors, cards, embed, handoff (locked)

**Locked on:** 2026-04-29 (final Topic 8 round closing all planning-shaped open items)

## System prompt structure

Every agent's system prompt follows a fixed 6-section template, persisted at `agents/<name>/system-prompt.md`, version-controlled. Tier-1 lints that all 6 H2 headings exist.

```markdown
# <Agent Name> — System Prompt

## 1. Identity
Who the agent is, what surface(s) it lives on, what it can/cannot do at a sentence level.

## 2. Voice & Tone
Pulled from `docs/voice-and-tone.md` per-agent row. Reading level, emoji policy, salutation template.

## 3. Persona context contract
Conversation variables the agent receives (`personaId`, `personaRole`, `primaryAccountId`, `primaryPatientId`, `surface`, `correlationId`). How to greet per persona. When to ignore persona (V6 outside-the-app surfaces).

## 4. Tool catalog
Enumerated tools (name + 1-line purpose + when to use). Confirm-before-write reminder. Standard envelope reminder.

## 5. Knowledge sources
SharePoint subfolders this agent can ground on. Citation rendering reminder. Freshness assumption ("docs are kept ≤7 days fresh by republish flow").

## 6. Safety & fallback rules
Safe-fallback wording (locked below). Refuse-list (no medical advice, no PII echo, etc.). Escalation path.
```

**Authoring rule:** the prompt text itself is Phase 5 work; this template is the Phase-0 contract. Phase 5 PRs touching `system-prompt.md` must keep all 6 sections present.

## Standard error codes

Added to `scripts/lib/AgentToolContract.schema.json` `errorCode` enum:

| Code | Meaning | Default user message template |
|---|---|---|
| `validation_failed` | Input failed schema validation | `"I need a bit more info: {hint}."` |
| `not_found` | Requested record doesn't exist | `"I couldn't find {entity} for that request."` |
| `forbidden` | Persona lacks permission for the operation | `"That action isn't available for your role."` |
| `dependency_failed` | Downstream system (Dataverse / Graph / SP) errored | `"Something on our side hiccuped. Want me to log a ticket?"` (triggers safe-fallback) |
| `rate_limited` | Throttle hit | `"Lots of activity right now — give me a moment and I'll retry."` |
| `timeout` | Operation timed out | Same as `dependency_failed` |
| `internal_error` | Unhandled exception | Same as `dependency_failed` |
| `data_conflict` | Optimistic concurrency / duplicate key | `"Looks like that's already been done. Latest record is {ref}."` |
| `consent_required` | Confirm-before-write returned no | `"No worries — I won't do that. Anything else?"` |
| `feature_disabled` | Feature flag off (Topic 4) | `"That part of the demo isn't enabled in this environment."` |

Per-tool error responses must use one of these codes; the user-facing message MAY override the default template (declared in the tool's flow).

## Adaptive Card templates

5 JSON templates committed under `solutions/ContinuumHealthDemo/src/AdaptiveCards/`:

### 1. `_persona-header-partial.json` (shared)
- Image: persona avatar (URL from persona context)
- Heading: persona name
- Subtitle: persona role
- Footer line: `via Continuum Health <surface>` (where `<surface>` ∈ Field Companion / Quality Workspace / Knowledge / Patient Portal)
- Used by every other card via Adaptive Card `selectAction`/`includes` pattern

### 2. `TriageCard.json` (V4 — sent to `cch_IdTeamsChannelQuality`)
- Border color: severity (Critical=red, High=orange, Medium=yellow, Low=green)
- Header partial with **agent persona** ("Quality Triage Agent" + bot avatar) + subtitle "On behalf of {analystPersonaName}"
- Body fields: complaint id, patient name, device lot, classification + confidence bar, MDR-clock countdown
- Buttons (3): `Open in Quality Workspace` (deep-link), `Acknowledge` (fires flow → status update), `Escalate` (fires `EscalateComplaint` tool)

### 3. `ChannelUpdateCard.json` (V3 reused by V5 — sent to `cch_IdTeamsChannelField` or `cch_IdTeamsChannelEnablement`)
- Header partial with **caller persona** (FCS or Enablement-tool invoker)
- Body: free-text message + optional `data` summary table (rendered from envelope)
- Buttons (1–2): `Open Account` (deep-link) and/or `Open in Code App`

### 4. `ToolResultCard.json` (V5/V6 inline — rendered in chat, not sent to Teams)
- Compact card body: ✓ icon + 1-line confirmation + result deep-link
- No persona header (lives inside chat where persona is implicit)
- One button max: `View in <area>`

### 5. `EscalationCard.json` (V4 — sent to `cch_IdTeamsChannelLeadership`)
- Variant of `TriageCard` with red border forced
- Header partial with **analyst persona** + subtitle "Escalated by {analystPersonaName}"
- Body: original triage summary + escalation reason + link to original `TriageCard`
- Buttons (2): `Open in Quality Workspace`, `Reply in thread`

## `<AgentChatHost/>` component (component #23)

Wraps Direct Line + the locked `cch_IssueDirectLineToken` flow.

**Props:**
- `agentId` — one of three agent IDs from env vars
- `size` — `floatingBubble | dockedPanel | fullScreen`
- `personaContext` — auto-injected from persona overlay store
- `onToolCall(toolName, result)` — callback for surfaces that want to render `<ToolResultCard/>` inline
- `onCitations(citations[])` — callback used by V5 sidebar

**Sizing:**
- `floatingBubble`: 380×600 desktop, full-screen on mobile (V1 + V2 + V3)
- `dockedPanel`: full-height, 420w right-edge (V3 docked + V4 docked)
- `fullScreen`: centered max-width 760, full chat (V5)

**Theming:** Continuum brand teal `#0E7C86` accent (Topic 2); Segoe UI Variable; light mode only (Topic 7).

**Telemetry:** auto-emits `AgentEvent` events per Topic 6 schema (start, turn, tool-call hooks).

## `<CitationsRenderer/>` component (component #24)

**Props:**
- `citations` — `[{title, url, excerpt?}]`
- `mode` — `sidebar | popover | teamsCard | m365`

**Modes:**
- `sidebar` — full-height list, V5 only
- `popover` — `[N]` footnotes that expand on click into a Fluent popover; V1/V2/V3
- `teamsCard` — Adaptive Card facts at the bottom of the agent reply; V6 Teams 1:1
- `m365` — passes through to M365 Copilot's native renderer; we just expose the `citations[]` envelope

Reads citations from the standard envelope; never invented client-side.

**Component library now: 24** (Topics 2 added 2, 7 added 3, 8C adds 2).

## Direct Line embed: persona context dispatch

- Persona context (`personaId, personaRole, primaryAccountId, primaryPatientId, surface, correlationId`) is set as **conversation variables** on Direct Line conversation start.
- Persona switch (locked Topic 7 announcer) → starts a **new** Direct Line conversation (per the locked memory model below).
- All persona-context dispatches go through `apps/.../lib/agentContext.ts` — single source of truth so the persona overlay store is the only place this state lives.

## Safe-fallback wording per agent

Pinned per-agent. Lives in each `agents/<name>/spec.md` § Voice & Tone.

### Patient Support — Patient persona
- Fallback: `"I want to make sure you get the right help. Let me create a callback request for the Continuum care team — you'll hear from someone within one business day. Sound good?"`
- Confirm ack: `"✓ Done. Your reference number is {ticketId}."`

### Patient Support — HCP / FCS personas
- Fallback: `"I don't have a confident answer here. Want me to log this so the right person on your team can follow up?"`
- Confirm ack: `"✓ Logged as request {ticketId}. I've notified <area>."`

### Patient Support — Anonymous
- Fallback: `"Let me get a Continuum support specialist to help. Could I grab a name and email so they can reach back out?"`
- Confirm ack: `"✓ Got it. Someone will be in touch soon."`

### Quality Triage (analyst chat)
- Fallback (no confirm — flag is the action): `"This is outside what I can confidently triage. I've flagged the case for human review and added a note to the activity timeline."`

### Continuum Enablement
- Fallback: `"I couldn't find a confident answer. Want me to flag this for the enablement team to add to the knowledge base?"`
- Confirm ack: `"✓ Flagged. The team will see this in their next review."`

## Prompt-starter chip behavior

Per-chip flag in the surface config file (`apps/.../config/promptStarters.ts`):

```ts
{ label: "Order box-of-30 G7s for Dr. Hancock", autoSend: false }   // write action — populate, let user adjust
{ label: "What's new in G7 Pro?",                 autoSend: true  } // read-only knowledge — auto-send
```

**Rule:** read-only chips (knowledge questions, status checks, briefings) auto-send; write-action chips (Order, Schedule, Submit, Post, Draft, Replace) populate-only. The chip-text inventory in 8B will be tagged with `autoSend: bool` per chip in Phase 2/3.

## Inter-agent handoff pattern

**No live conversational handoff.** When Patient Support (in any persona mode) fires `FileComplaint`:
1. Tool returns envelope with `complaintId` + `mdrClockExpiresAt`.
2. Agent renders confirmation: `"✓ Complaint {complaintId} filed. Our quality team will review within {mdrClockHours}h."`
3. Conversation ends naturally; agent does not transfer to Quality Triage.
4. Quality Triage's autonomous trigger (locked `cch_TriggerQualityTriage`) handles the rest in background.
5. Operator (or audience) sees the V4 Quality Workspace updates from a *different* persona/surface — that's the demo beat.

For V3 (FCS submitting complaint on behalf of account): same pattern, plus the Account 360 drawer's complaint section animates the new row in.

## Conversation memory

- **Per-conversation only.** Each Direct Line conversation maintains its own context window (Copilot Studio default).
- **New conversation on persona switch.** When `<PersonaSwitchAnnouncer/>` fires, the agent host disposes the current Direct Line conversation and starts a fresh one with new persona context.
- **No cross-conversation persistence** — keeps demos predictable and avoids PII-style retention concerns.
- **Surface change** (e.g. user closes V3 docked panel and reopens) within the same persona resumes the same conversation if `<AgentChatHost/>` is still mounted; otherwise starts new.

## Knowledge doc freshness signaling

- **No staleness disclaimers in agent answers.**
- The locked weekly templated-doc republish flow (handoff §3.9) refreshes `lastReviewed` to `{{today}}` on every run — by design, no doc is ever older than ~7 days.
- Doctor's `Knowledge` section (Topic 8B) warns at >8 days so the operator catches a broken republish flow before it shows up in agent answers.
- `<CitationsRenderer/>` shows the doc title + excerpt; explicit "last reviewed" date is *not* surfaced in citation UI to avoid the visual clutter.

## Updates to earlier locked decisions

- **Component library** — grows from 22 to **24** (`<AgentChatHost/>`, `<CitationsRenderer/>`).
- **Topic 6 telemetry** — `<AgentChatHost/>` is the canonical emit point for client-side `AgentEvent` events; payload allowlist gains `agentId`, `conversationId`, `turnIndex`, `toolName`.
- **Topic 4 env vars** — no new env vars; reuses existing `cch_IdAgent*` and `cch_SecretDirectLine*`.
- **Handoff §3.11 repo layout** — adds:
  - `agents/<name>/system-prompt.md` × 3
  - `solutions/ContinuumHealthDemo/src/AdaptiveCards/` × 5 templates
  - `apps/field-companion/src/lib/agentContext.ts` (and Pages mirror)
- **Topic 8 spec.md per agent** — voice & tone section gains the per-agent fallback wording above.

## Topic 8C deliverables

1. **Append 8C section to `docs/_planning/topic-08-agents.md`** ✅ done
2. **`agents/<name>/system-prompt.md`** × 3 skeletons with all 6 H2 headings (text TBD Phase 5)
3. **`scripts/lib/AgentToolContract.schema.json`** — `errorCode` enum added
4. **`solutions/ContinuumHealthDemo/src/AdaptiveCards/{TriageCard, ChannelUpdateCard, ToolResultCard, EscalationCard, _persona-header-partial}.json`** — 5 templates
5. **Component-library additions:** `<AgentChatHost/>` and `<CitationsRenderer/>` scheduled for Phase 2/3
6. **Per-agent fallback wording** added to each `agents/<name>/spec.md` § Voice & Tone (Phase 5 spec authoring inherits this)

## Final Topic 8 — what's now in scope vs. out of scope

**In scope (locked across 8 + 8B + 8C):** agent identities · tool envelope + error codes · standard tool list (18 tool flows) · trigger contract for V4 · per-tool telemetry wrapper · M365 readiness checklist · knowledge inventory + ACLs · prompt-starter chip text + behavior · system-prompt template · 5 Adaptive Card templates · `<AgentChatHost/>` + `<CitationsRenderer/>` components · safe-fallback wording · inter-agent handoff pattern · conversation memory model · freshness signaling.

**Out of scope (Phase 5 authoring):** system prompt **text** · per-topic training utterances · per-tool error message overrides beyond defaults · Adaptive Card visual polish (colors, spacing) · per-agent live tuning of confidence thresholds · iterative prompt refinement.
