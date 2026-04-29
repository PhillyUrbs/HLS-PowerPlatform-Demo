# Topic 6 — Telemetry / observability (locked)

**Locked on:** 2026-04-29
**Scenario layer:** 🟢 **Scenario-agnostic** — `cch_TelemetryEvent` schema, 6 event categories, `cch_LogTelemetry` child-flow checkpoint pattern, allowlist+hash+drop-free-text redaction, 30-day retention, Demo Health tile architecture, doctor `[Telemetry]` section. All identical regardless of scenario. Forking: swap prefix; the `eventName` strings will reflect new vignettes naturally.

## Framing

- Locked **runtime independence** (§3.14) rules out App Insights / Log Analytics / external collectors.
- Our "observability stack" = **native PP signals + one `cch_TelemetryEvent` Dataverse table + Demo Health page**.
- Builds on existing locked surfaces: §3.9 Demo Health, §3.17 doctor + smoke + Direct Line pings.

## Decisions

| Area | Decision | Rationale |
|---|---|---|
| **Approach** | Native PP signals (flow run history, agent analytics, Pages analytics) + one `cch_TelemetryEvent` table for app-side events the platform doesn't capture. Surface through Demo Health | Honors locked runtime independence; zero external services |
| **Event categories** | Persona switches · Vignette beats · Agent conversation events (start/turn/tool-call/error) · Client-side errors · Performance marks · Demo Health control invocations | Covers the gaps the platform doesn't capture; explicitly excludes page views (Pages analytics covers it) and form-field interactions (PII-shaped noise) |
| **Schema** | Narrow filterable columns + one `PayloadJson` for category-specific data. See "Schema" below | Fast queries for Demo Health; categories evolve without schema migrations |
| **Agent mirroring** | Mirror **only what Copilot Studio analytics misses** (tool-call success/failure, tool-call latency, deflection signals). Live demo views CS analytics; Demo Health joins our mirror with conversation context | Cross-checking story for V6 closer; minimal write volume |
| **Flow telemetry** | `cch_LogTelemetry(category, eventName, severity, payload)` child flow invoked at checkpoint by every flow | Standardizes the cross-flow signal; joinable with native run-history |
| **Redaction** | Allowlist of safe field names + hash-by-default (SHA-256 short prefix) + drop free-text (replace with `[redacted: <length> chars]`) | Synthetic data is still PII-shaped; eliminates audit-permissions noise on `cch_TelemetryEvent` |
| **Retention** | 30 days; nightly bulk-delete inside the locked 5am ET daily refresh flow | Prevents Dataverse storage warnings in dev env |

## `cch_TelemetryEvent` table spec

| Column | Type | Notes |
|---|---|---|
| `cch_TelemetryEventId` | Uniqueidentifier (PK) | Auto |
| `cch_Timestamp` | DateTime | Indexed; default `utcnow()` |
| `cch_Category` | Choice | `PersonaSwitch`, `VignetteBeat`, `AgentEvent`, `ClientError`, `PerformanceMark`, `DemoHealthControl` |
| `cch_EventName` | Text(200) | E.g. `vignette.v4.triage.started`, `agent.toolcall.failed` |
| `cch_Surface` | Choice | `CodeApp`, `Pages`, `Agent`, `Flow`, `DemoHealth` |
| `cch_PersonaId` | Text(64) | Logical id from persona overlay; nullable for `Anonymous` / pre-overlay events |
| `cch_SessionId` | Text(64) | Persisted in localStorage with the persona; carries across persona switches |
| `cch_CorrelationId` | Text(64) | Direct Line conversation id / flow run id / Pages request id |
| `cch_Severity` | Choice | `Info`, `Warn`, `Error` |
| `cch_PayloadJson` | Multi-line text | Category-specific JSON; redaction-applied before write |
| `cch_IsTestRun` | Boolean | Tagged when emitted during E2E (locked §3.17 isolation pattern) |

**Indexes:** `cch_Timestamp DESC`, `cch_Category + cch_Timestamp DESC`, `cch_Severity + cch_Timestamp DESC`, `cch_CorrelationId`.

## Telemetry SDK spec

### React (`apps/field-companion/src/lib/telemetry.ts`, `sites/continuum-portal/src/lib/telemetry.ts` — shared via the component library)

```ts
type Category = 'PersonaSwitch' | 'VignetteBeat' | 'AgentEvent' | 'ClientError' | 'PerformanceMark' | 'DemoHealthControl';
type Severity = 'Info' | 'Warn' | 'Error';

interface TelemetryEvent {
  category: Category;
  eventName: string;
  surface: 'CodeApp' | 'Pages' | 'Agent' | 'Flow' | 'DemoHealth';
  severity?: Severity;        // default: Info
  correlationId?: string;     // default: current session
  payload?: Record<string, unknown>;
}

logTelemetry(event: TelemetryEvent): Promise<void>;
withPerformanceMark<T>(name: string, fn: () => Promise<T>): Promise<T>;
captureGlobalErrors(): void;  // wires window.onerror + unhandledrejection
```

- **Batching:** in-memory ring buffer, flushed every 5s or 20 events, whichever first.
- **Transport:** Pages Web API or Code App Dataverse SDK depending on surface; one POST to `cch_TelemetryEvent`.
- **Redaction:** runs *before* enqueue. Allowlist + hash + free-text drop applied to `payload`.
- **Persona/session context:** auto-attached from the persona overlay store; never passed by callers.
- **Failure mode:** swallow errors silently; never break the app to log telemetry.

### Power Automate child flow `cch_LogTelemetry`

| Input | Type | Notes |
|---|---|---|
| `category` | string | Must match a Choice value |
| `eventName` | string | |
| `severity` | string | default `Info` |
| `correlationId` | string | typically the parent flow's run id |
| `payload` | object | redaction applied here as well |

**Output:** none (fire-and-forget). Errors swallowed; never fails the parent flow.

### Payload JSON Schema (`scripts/lib/TelemetryPayload.schema.json`)

One `oneOf` per category. Each subschema declares its allowlist; CI Tier-1 `audit-permissions` enhancement validates that React/Flow callers don't drift from the schema.

### Redaction allowlist (initial)

`vignetteId`, `beatName`, `route`, `componentName`, `agentId`, `toolName`, `toolStatus`, `latencyMs`, `httpStatus`, `errorCode`, `errorMessage` (truncated to 200 chars), `personaRole`, `entityName` (logical), `recordId` (hashed), `lotNumber` (hashed), `severityChip`.

Anything not on the allowlist → SHA-256 hash, first 8 hex chars. Free-text fields (`narrative`, `notes`, `description`, `mdrDraft`) → dropped, replaced with `[redacted: <length> chars]`.

## Demo Health page additions (Phase 3 work)

Beyond locked §3.9:

1. **Recent persona switches** strip (last 10) — chip per switch with surface + timestamp
2. **Errors panel** (last 20 client/agent/flow errors) — severity-colored rows with deep links to flow run / agent conversation / client stack snippet
3. **Sparkline tiles**:
   - Agent tool-call latency p50/p95 (last 1 hour)
   - Flow success rate (last 24 hours)
   - Refresh-flow age (time since last refresh)
4. **Heartbeat tile** — "Last live-sim event: 6 min ago" / "Last refresh: today 5:00am ET" with red/yellow/green
5. **Warm up button** — sequences common Demo Health controls (refresh-now, inject-complaint, ping-each-agent) to pre-warm caches before going live
6. **Embedded Copilot Studio analytics tile** — iframe of CS analytics for the Continuum Enablement agent (V5/V6 hero) on the Demo Health page

Operator-only nav (per Topic 3 `DemoOperator` security role).

## Doctor `Telemetry` section spec

```
[Telemetry]
- cch_TelemetryEvent: row count last 1h         [pass: > 0 | warning: 0 (apps inactive?)]
- Errors last 24h                               [pass: 0 | warning: < 5 | error: >= 5]
- Agent tool-call success rate last 24h         [pass: >= 95% | warning: 80-95 | error: < 80]
- Flow success rate last 24h                    [pass: >= 95% | warning: 80-95 | error: < 80]
- Oldest event > retention (30d)                [pass | warning: bulk-delete behind]
- cch_LogTelemetry child flow: enabled?         [pass | warning: disabled]
- Redaction policy: schema validation passes?   [pass | warning: payload schema drift]
```

All info/warning/error reporting only — never gates, never mutates (locked doctor rule).

## Updates to earlier locked decisions

- **Handoff §3.9 Demo Health** — gains the 6 additions enumerated above; nav remains operator-only (locked Topic 3 `DemoOperator`).
- **Handoff §4 Custom tables** — adds **`cch_TelemetryEvent`** to the initial schema.
- **Handoff §3.11 repo layout** — adds:
  - `scripts/lib/TelemetryPayload.schema.json`
  - Shared `lib/telemetry.ts` referenced by both Code App and Pages
  - Flow `cch_LogTelemetry` (child flow) inside the solution
- **Topic 4 env vars** — no new env vars (intentional; telemetry config lives in Dataverse, not env vars).
- **Handoff §3.16 Tier 1** — gains a new check: payload-schema-drift validator (every React `logTelemetry` call site must match `TelemetryPayload.schema.json`).
- **Topic 5 V6 governance closer** — gains a 4th talking point (optional fold-in at demo-script time): *"every operational signal — agent, flow, client — lives in this one tenant, in one Dataverse table, queryable, auditable, deletable. No external observability stack to license, govern, or breach."*

## Deliverables to commit

1. **`docs/_planning/topic-06-telemetry.md`** ← this file
2. **`docs/telemetry.md`** — operator-facing reference: schema, sample payloads, redaction allowlist, retention policy, Demo Health surfacing
3. **Telemetry SDK spec** above implemented in:
   - `apps/field-companion/src/lib/telemetry.ts` and Pages mirror (Phase 2/3)
   - `cch_LogTelemetry` child flow inside the solution (Phase 4)
   - `scripts/lib/TelemetryPayload.schema.json` (Phase 0 stub, fleshed in Phase 4)
4. **`cch_TelemetryEvent` table spec** above authored in Phase 1 schema
5. **Demo Health page additions list** above scheduled for Phase 3
6. **Tier-1 payload-schema-drift validator** added to `.github/workflows/ci-tier1.yml`

## Open follow-ups (deferred — not blocking)

- **Per-vignette beat catalog** (the canonical `eventName` strings) — enumerated when each vignette is built; seeded by Topic 1 click-paths.
- **Sparkline aggregation queries** (FetchXML or Web API) — implementation detail; lands with Demo Health Phase 3.
- **Optional App Insights exporter** (the OTel-shape rejected option) — left as a documented "future enhancement" in `docs/telemetry.md`; not implemented.
- **Pages analytics tile** on Demo Health (page views, top routes) — could fold in if useful at Phase 3.
