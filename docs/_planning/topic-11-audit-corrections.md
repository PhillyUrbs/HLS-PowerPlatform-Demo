# Topic 11 — Audit corrections (locked)

**Locked on:** 2026-04-29
**Scenario layer:** 🟢 **Scenario-agnostic (framework)** — the *audit-corrections-doc-supersedes-earlier-topics* pattern + the second-pass-addendum pattern are reusable for any planning corpus. The specific corrections C1–C12 + A1–A3 are Medtech-scenario-specific (component count, vignette V6 sync, etc.) and *won't* port. Forking: copy the *pattern* of having a Topic 11; redo the audit fresh on the new scenario's planning corpus.
**Source:** post-planning audit of Topics 1–10 + handoff-2026-04-28.md
**Status:** This doc is the **authoritative correction layer**. Where it conflicts with earlier topic docs, this doc wins. The earlier docs are preserved as-is for historical context.

## How to read this doc

Each correction has:
- **Affects** — which doc + section the correction supersedes
- **Reading** — the corrected statement (use this in any future reference)
- **Why** — one-sentence rationale from the audit

---

## Corrections (must-fix)

### C1. Component library count
- **Affects:** handoff §5 opening line ("12+ components"); Topic 7 ("19 → 22"); Topic 8C ("Component library now: 24")
- **Reading:** Final locked count is **23 React components + 1 CSS utility class (`sr-only`)**.
- **Why:** Topic 7 grouped `sr-only` (a CSS utility class, not a React component) into the React-component count. The strict enumeration is 23 components. References to "24 components" should be read as "23 components + 1 utility" going forward.
- **Roll-up:**

  | Source | Adds | Net |
  |---|---|---|
  | Handoff §5 | 17 components | 17 |
  | Topic 2 | `<ContinuumLogo/>`, `<DemoModeBanner/>` | 19 |
  | Topic 7 | `<ReducedMotionProvider/>`, `<PersonaSwitchAnnouncer/>` (+ `sr-only` utility) | 21 components + 1 utility |
  | Topic 8C | `<AgentChatHost/>`, `<CitationsRenderer/>` | **23 components + 1 utility** |

### C2. Handoff §5 header typo
- **Affects:** handoff-2026-04-28.md §5 first line
- **Reading:** "## 5. Reusable component library (**17+ components**)" — corrects the "12+" typo. The table immediately below was always 17.
- **Why:** Founding handoff has a typo; never affected downstream planning because all topics built from the table, not the header.

---

## Corrections (should-decide; pinned now)

### C3. Phase 0 sizing reality
- **Affects:** Topic 10 + 10B first-PR targets framing
- **Reading:** Phase 0 will land in **multiple sittings, not one**. Order of operations:
  1. Sitting 1: commit pending local-only files (handoff §2 list) + this Topic 11 doc.
  2. Sitting 2: `squad init` + `.squad/charter.md` + 7 subfolder AGENTS.md + `.squad/phase.json` + `Seed-Decisions.ps1` + decisions.md seeded.
  3. Sitting 3: PR template + CODEOWNERS + branch protection + Tier-1 workflow skeleton + `data/names/people.md` (already populated by user).
  4. Sittings 4+: 4 governance script stubs + `install.ps1`/`upgrade.ps1`/`uninstall.ps1`/`doctor.ps1` skeletons + `scripts/lib/EnvVarManifest.json` + `deployment-settings.json.template` + JSON Schema + 9 GitHub issues opened.
  5. Sitting N: Phase-0-complete checkpoint; phase.json bumps to Phase 1.
- **Why:** Adding up the full Phase 0 work across the planning corpus, ~12 distinct deliverables. Single-sitting was unrealistic in earlier framing.

### C4. Tier-1 budget revision
- **Affects:** handoff §3.16 ("~30s")
- **Reading:** Realistic Tier-1 budget is **60–90s**, not 30s. ~19 checks accumulated across topics; axe-core + audit-permissions are the slowest. Phase 0 measures actual runtime; if > 120s, Tester proposes which checks to demote to Tier 3 (candidates: `audit-permissions` and axe could move to Tier 1.5 = "fast vs. comprehensive" split, or run only on touched-folder PRs).
- **Why:** Original 30s assumed ~11 lightweight checks; we added 8 more, several non-trivial.

### C5. Flow count consolidation
- **Affects:** Topic 8 ("18 distinct tool flows + 5 infrastructure = 23")
- **Reading:** **Final flow count: ~30–34 flows** in the solution at full implementation. Categories:
  - **18** tool flows (Topic 8 — 12 Patient Support + 8 Quality Triage − 2 shared)
  - **5** infrastructure flows: `cch_ResolveSecret`, `cch_LogTelemetry`, `cch_AgentToolWrapper`, `cch_IssueDirectLineToken`, `cch_TriggerQualityTriage`
  - **~7–11** lifecycle/orchestration flows: V1 replacement orchestration, shipment lifecycle advancer (compressed-time), live-events simulator, daily refresh (5am ET), 6 vignette-reset flows (one per vignette), templated-doc weekly republish
- **Why:** Topic 8's "23 core flows" framing didn't include the lifecycle category from handoff §3.9 + §3.14. Flows-Engineer scope is ~30–34, not 23.

### C6. Cross-cutting ownership: Demo Health row
- **Affects:** Topic 10B Cross-cutting ownership table, "Demo Health page" row
- **Reading:** Drop **Flows-Engineer** from the secondary list. Demo Health reads telemetry directly via Web API/Dataverse SDK, not via flows. Updated row:

  | Artifact | Primary | Secondary | Arbiter |
  |---|---|---|---|
  | Demo Health page | CodeApp-Engineer | Tester (doctor JSON contract); Governance (governance posture data) | Lead |

- **Why:** No realistic Flows-Engineer touchpoint on Demo Health rendering.

### C7. Voice & tone short-doc owner
- **Affects:** Topic 2 deliverable list (implied branding ownership) vs. Topic 10B cross-cutting table (Scribe owns)
- **Reading:** **Voice & tone short-doc (`docs/voice-and-tone.md`) is owned by Scribe.** Agent-Builder reviews per-agent rows for fidelity to Topic 8 voice & tone table. Branding role does not exist in Squad; Topic 2 deliverable should be read as "owned by Scribe; coordinated with branding decisions in `docs/branding.md`."
- **Why:** Topic 2 was authored before Topic 10's role definitions; ambiguity surfaced in audit.

### C8. Anonymous web role vs. agent grounding ACL
- **Affects:** Topic 8B knowledge ACLs ("Anonymous: none") vs. Topic 8 Patient Support agent grounding for Anonymous persona
- **Reading:** No conflict; **clarifying note** required in `agents/AGENTS.md`. The agent grounds on `data/knowledge/Patient/` using **the SP identity** (Topic 3 `ServicePrincipal` security role). The anonymous browser user **never** reads from SharePoint; only the agent (running as SP) does. The user-facing chat surfaces grounded answers via the Direct Line conversation.
- **Why:** Could confuse a future contributor "fixing" the anonymous ACL to allow read; this clarification prevents that.
- **Action at Phase 0 commit:** Add this paragraph verbatim to the `agents/AGENTS.md` House Rules section under a new bullet: *"Anonymous browser users never read from SharePoint directly; the agent reads as SP identity and surfaces answers via Direct Line. Do not 'fix' Topic 8B's `Anonymous: none` ACL."*

### C9. Branch naming format
- **Affects:** handoff AGENTS.md ("`feature/<phase-or-vignette>`"); Topic 10 ("`feature/<phase>-<name>`"); Topic 10 Tier-1 lint
- **Reading:** **Format = `feature/p<N>-<name>`** where `<N>` is the numeric phase (0–6) and `<name>` is kebab-case. Examples: `feature/p0-tier1-workflow`, `feature/p1-schema-baseline`, `feature/p2-pages-shell`, `feature/p4-infrastructure-flows`. Tier-1 lint regex: `^feature/p[0-6]-[a-z0-9-]+$` (warning, not block).
- **Why:** Multiple plausible interpretations of `<phase>` (number vs. name vs. abbreviation). Picking one now prevents drift.

---

## Corrections (Phase-time decisions; capture as risks)

### C10. Embedded Copilot Studio analytics iframe
- **Affects:** Topic 6 Demo Health additions (tile #6: "Embedded Copilot Studio analytics tile (iframe to CS analytics)")
- **Reading:** **Phase 3 spike required.** Cross-domain iframe into Power Platform analytics typically needs SSO context that may not work cleanly inside a Code App's iframe sandbox. CodeApp-Engineer runs a 1-day spike at Phase-3 start. Acceptance criteria: tile loads CS analytics for the Continuum Enablement agent under the demo super user's session within the Code App. **If spike fails:** fall back to a "Open CS Analytics" deep-link button (no iframe). Either outcome lands as a `decisions.md` entry.
- **Why:** No existing topic flagged this as a risk; iframe SSO across Microsoft properties is famously inconsistent.

### C11. Pages-Engineer install prerequisite
- **Affects:** Topic 10 first-PR targets (Pages-Engineer Phase 2)
- **Reading:** **Implicit prerequisite:** Pages-Engineer's Phase 2 PR #1 (Pages scaffold + auth wiring) requires `install.ps1` to provision the Entra app reg for Pages auth (`cch_IdEntraAppPagesAuth` env var). Lead must complete `install.ps1`'s Entra-app-reg provisioning step before Pages-Engineer's first auth-touching PR. **Ordering:**
  1. Lead Phase 0: install.ps1 skeleton (stubbed) ✓ (locked first-PR target)
  2. Lead Phase 0/1: install.ps1's `provision-entra-apps` mode actually works
  3. Pages-Engineer Phase 2 PR #1: Pages scaffold (no auth) — can proceed in parallel with #2
  4. Pages-Engineer Phase 2 PR #2: Pages auth wiring — gated on #2
- **Why:** Easy to mis-sequence and waste a sitting if Pages-Engineer starts auth wiring before the Entra app exists.

### C12. V6 conversation-reset narration
- **Affects:** Topic 9 V6 demo-script section
- **Reading:** Per Topic 8C's "new conversation on persona switch" + V6's surface-hopping (Code App → Teams 1:1 → SharePoint → M365 Copilot), the audience will see the *same question re-asked, getting the same answer, in a fresh conversation each time*. **Narration line for Phase-6 author:** *"Notice each surface starts fresh — that's intentional. The agent doesn't carry conversation state across surfaces; what carries across is the underlying knowledge, governance, and identity."*
- **Why:** Without narration, the lack of conversation continuity could read as a bug rather than a design choice.

---

## Doctor JSON output schema pin

Should-decide item from audit (Doctor sections at 7+). Pinning now to avoid Phase-3 churn:

```json
{
  "version": "1.0",
  "runId": "<uuid>",
  "ranAt": "<iso-8601>",
  "vignette": "V_|null",
  "mode": "full|chained|highlight|null",
  "sections": [
    {
      "name": "Permissions|EnvVars|Governance|Telemetry|A11y|Knowledge|Squad|Agents",
      "findings": [
        {
          "id": "<short-stable-id>",
          "severity": "pass|info|warn|error",
          "title": "<one-line>",
          "detail": "<optional multi-line>",
          "deepLink": "<url|null>"
        }
      ]
    }
  ]
}
```

Used by Demo Health pre-flight buttons + Tier-3 nightly summary + V6 governance closer screen-share.

---

## Updates to earlier locked decisions

- **Handoff §5** — "12+" superseded by "17+" per C2; final library count per C1.
- **Topic 7** — "19 → 22" superseded by "21 components + 1 utility" per C1.
- **Topic 8C** — "Component library now: 24" superseded by "23 components + 1 utility" per C1.
- **Topic 8 / Flows-Engineer scope** — "23 flows" superseded by "~30–34 flows" per C5.
- **Topic 10B Cross-cutting ownership** — Demo Health row: drop Flows-Engineer from secondary per C6.
- **Topic 2 / Topic 10B** — Voice & tone owner = Scribe per C7.
- **Handoff §3.16 / Topic 10** — Tier-1 budget revised to 60–90s per C4.
- **Topic 10** — Branch naming pattern pinned per C9.
- **Topic 6** — CS analytics iframe flagged as Phase-3 spike per C10.
- **agents/AGENTS.md (Topic 10B prose)** — gains anonymous-vs-agent ACL clarification per C8 at Phase 0 commit time.

## Deliverables to commit

1. **`docs/_planning/topic-11-audit-corrections.md`** ← this file
2. **At Phase 0 final commit** — apply C8 clarification line to `agents/AGENTS.md` before commit
3. **At Phase 0 final commit** — set Tier-1 lint regex from C9 in `.github/workflows/ci-tier1.yml`
4. **At Phase 3 start** — file the C10 spike as a Squad issue assigned to CodeApp-Engineer
5. **At Phase 6 demo-script authoring** — include C12 narration line in V6 talk track

## Memory + decisions.md seed update

When `Seed-Decisions.ps1` runs at `squad init`, it now seeds **11 entries**, not 10 (Topics 1–11). Each entry uses the locked entry shape; Topic 11's entry summarizes the audit + lists the 12 corrections by ID.

---

## Second-pass audit addendum (2026-04-29)

A second-pass audit run after Topic 11 + name-swap commit surfaced 3 follow-up items. Two were resolved at the same commit; one is a forward-looking note.

### A1. README.md + `.github/copilot-instructions.md` listed 5 vignettes (RESOLVED)
- **Affects:** `README.md` Scenario section; `.github/copilot-instructions.md` § Vignettes
- **Issue:** Both root docs predated the V6 lock and listed only 5 vignettes. Anyone reading the repo cold would have missed V6 ("Extend everywhere").
- **Fix applied (2026-04-29):**
  - `README.md`: now lists 6 vignettes; also corrected stale "mocked carrier API" phrasing to "in-platform Shipment lifecycle (no external services)" per locked §3.14; Status section updated to reflect planning-complete state.
  - `.github/copilot-instructions.md`: § Vignettes header now `(6, each demoable standalone or chained 1→6)`; V6 added.
- **Status:** ✅ closed.

### A2. Tier-1 budget reality (~30s → 60–90s) — needs decisions.md seed entry
- **Affects:** handoff §3.16 ("~30s") vs. Topic 11 C4 (60–90s realistic)
- **Issue:** Handoff is locked and still claims ~30s. Phase 0 implementer needs to know the real budget *before* they start measuring or designing the Tier-1 workflow.
- **Action for `Seed-Decisions.ps1`:** Topic 11's seeded entry must explicitly call out the C4 revised budget so it appears in `.squad/decisions.md` from day one. Suggested entry text fragment:
  > **Decided (C4):** Tier-1 CI budget revised to 60–90 seconds. Original handoff §3.16 estimate of ~30s assumed ~11 lightweight checks; we accumulated ~19 across topics. Tester measures in Phase 0; if > 120s, demote `audit-permissions` and `axe-core` to a touched-folder-only or Tier-1.5 split.
- **Status:** queued for Phase 0 commit.

### A3. Entra app provisioning sequencing — needs decisions.md seed entry
- **Affects:** Topic 11 C11 (Pages-Engineer install prerequisite) + Topic 10B Lead first-PR target
- **Issue:** C11 says Pages auth wiring (Phase 2 PR #2) requires Entra app reg provisioning to actually work. Topic 10B says Lead's first PR is install.ps1 *skeleton* (stubbed). C11 doesn't pin **which** Lead PR delivers working Entra provisioning.
- **Decision (locked now to remove ambiguity):** Lead's **first PR after the skeleton** (i.e. Lead's PR #2, still Phase 0) makes `install.ps1 -Mode install` actually provision the two Entra app regs (`cch_IdEntraAppPagesAuth` for Pages auth + `cch_IdEntraAppServicePrincipal` for SP). Sequencing:
  1. Lead PR #1 (Phase 0): install.ps1 skeleton + mode dispatcher (NotImplemented exits) — locked.
  2. **Lead PR #2 (Phase 0): `Setup-ServicePrincipal.ps1` + install.ps1 `provision-entra-apps` step (real)** — NEW lock.
  3. Pages-Engineer PR #1 (Phase 2): scaffold + DemoModeBanner + ContinuumLogo (no auth) — can run parallel to Lead PR #2.
  4. Pages-Engineer PR #2 (Phase 2): Pages auth wiring — gated on Lead PR #2 completion.
- **Action for `Seed-Decisions.ps1`:** seed an entry capturing this sequence so the constraint is visible from `.squad/decisions.md` day one.
- **Status:** locked; queued for Phase 0 commit.

### Updated `Seed-Decisions.ps1` entry count
The Topic 11 seeded entry now incorporates A1–A3 as sub-bullets under the Topic 11 entry (no separate "Topic 12" needed). Total seeded entries remains **11**.
