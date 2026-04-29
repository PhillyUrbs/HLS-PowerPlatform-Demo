# Topic 9 — Demo script outline (locked)

**Locked on:** 2026-04-29
**Scenario layer:** 🟡 **Hybrid** — *Structure agnostic* (single-file `docs/demo-script.md` shape, 8-element vignette inner template, 1-min Intro+Closer, inline `[BDM]/[TDM]/[both]` audience tags, highlight-reel concept, 8 Demo Health pre-flight buttons, doctor `--vignette=V_` invocation pattern, recovery cookbook chapter structure, 7 appendices). *Content scenario-specific* (cast bios, hero names, V1–V6 click-paths + Q&A inventory + recovery entries, vignette-specific pre-flight checklists, V6 conversation-reset narration). Forking: keep template; rewrite vignettes + cast + Q&A.

## Framing

- Locked **6 vignettes** (handoff §3.2 + §7), demoable standalone or chained 1→6.
- Locked **lengths:** V1 6–9 / V2 5–7 / V3 6–8 / V4 7–9 / V5 5–7 / V6 3–4 minutes. Total chained ≈ **32–44 min**.
- Locked **demo-script.md is Phase 6 work** (handoff §3.11).
- This topic pins the **shape + skeleton** so Phase 6 is fill-in-the-blanks.

## Decisions

| Area | Decision |
|---|---|
| **File shape** | Single `docs/demo-script.md` with 6 vignette sections + Intro + Closer + appendices. Both standalone and chained modes rendered from the same source via section flags |
| **Inner template** | 8 elements per vignette: TL;DR · Pre-flight checklist · Beat-by-beat table · Recovery moves per beat · Q&A anticipation (BDM/TDM-tagged) · Bridge-out · Demo Health watch tiles · "This vignette is *not*…" scope-line |
| **Intro + Closer** | 1-min Intro + 1-min Closer (Closer reuses Topic 5 + 6 talking-point bullets) |
| **Audience tracks** | Inline `[BDM]` / `[TDM]` / `[both]` tags on beats + Q&A. One script, not two |
| **Persona + data prep** | Folded into the per-vignette Pre-flight checklist; no separate section |
| **Highlight reel** | V1 + V4 + V6 in ~12 min — hook → hero → close |
| **Doctor coupling** | Demo Health gains **8 pre-flight buttons** (one per vignette + chained + highlight reel); script's Pre-flight checklist becomes "click button, verify all green" |

## Vignette inner template

```markdown
## V<N> — <Title>

**TL;DR:** <one-line hook> · <one-line outcome> · ~<min> min · `[BDM | TDM | both]`

**This vignette is *not*:** <one-line scope-line>

### Pre-flight
- [ ] Click "Pre-flight for V<N>" on Demo Health (or run `doctor.ps1 --vignette=V<N>`)
- [ ] Persona starting state: <persona name>
- [ ] Browser tabs: <list>
- [ ] Last refresh < 24h
- [ ] (other vignette-specific items)

### Beat-by-beat
| # | Beat | Click path | Talk track (annotated bullets) | Audience sees | Time |
|---|---|---|---|---|---|
| 1 | <name> | <click path> | • <bullet> `[BDM]`<br>• <bullet> `[TDM]` | <ui state> | 0:30 |
| 2 | … | … | … | … | … |

### Recovery moves
| If… | Then… |
|---|---|
| Live-sim row doesn't appear | Click "Inject" on Demo Health; narrate the manual injection |
| Agent slow/timeout | Switch to docked-panel pre-warmed conversation; <fallback wording from Topic 8C> |
| Adaptive Card doesn't post | Open Teams channel directly; show prior cards from previous run |
| (other beat-specific) | … |

### Q&A anticipation
| Q | A | Audience |
|---|---|---|
| "How does this scale to a real Quality team?" | <answer> | `[BDM]` |
| "Is this Microsoft Cloud for Healthcare?" | <answer — see 'What this is NOT' appendix> | `[both]` |
| "Where does the AI run?" | <answer — Topic 4 architecture summary> | `[TDM]` |
| (5–10 total) | … | … |

### Bridge-out (chained mode only)
> One sentence handing the audience to V<N+1>: "…and that complaint is exactly what V<N+1> picks up next."

### Demo Health watch
- Errors panel — should be 0
- Heartbeat tile — last live-sim < 12 min
- Sparkline — agent latency p95 < 3s
- (other vignette-specific tiles)
```

## File structure

```
docs/demo-script.md
├── Title + version + last-updated
├── How to use this script (3 paragraphs)
├── Demo modes
│   ├── Standalone vignette
│   ├── Chained 1→6
│   └── Highlight reel (V1 + V4 + V6)
├── Intro (1 min — chained/highlight only)
├── V1 — Patient onboarding & in-context support
├── V2 — HCP prescribing & patient roster
├── V3 — Field Clinical Specialist account 360
├── V4 — Autonomous complaint triage & MDR drafting
├── V5 — Employee enablement agent
├── V6 — Extend everywhere
├── Closer (1 min — chained/highlight only)
└── Appendices
    ├── A. Cast of characters
    ├── B. Glossary
    ├── C. Recovery cookbook (cross-vignette)
    ├── D. Demo-modes matrix
    ├── E. What this is NOT
    ├── F. Pre-demo 30-min runbook
    └── G. Demo Health controls quick-reference card
```

## Intro (1 min)

```
[BDM]   Contoso Continuum Health makes continuous glucose monitors. They sell to clinics,
        ship to patients, support both, and triage real-world complaints. Today you'll see
        how Power Platform supports four roles end-to-end:
        - a Patient registering and getting AI-assisted support
        - an Endocrinologist managing a roster
        - a Field Clinical Specialist managing accounts
        - a Quality Analyst handling complaints — partly autonomously
[TDM]   Everything you'll see runs on Power Pages, Power Apps Code Apps, Power Automate,
        Copilot Studio, and Dataverse. No external services. Synthetic data only.
        About 35 minutes — feel free to interrupt.
```

## Closer (1 min)

Three bullets — adapted from Topic 5 governance closer + Topic 6 telemetry closer + Topic 8 multi-surface story:

```
1. One platform, six surfaces, three agents — one DLP, one audit, one observability story.
2. Same Continuum Enablement Agent answered the same question in Code App, Teams, SharePoint,
   and M365 Copilot. One build, four surfaces, central governance.
3. Every operational signal — agent, flow, client — lives in this one tenant. No external
   observability stack to license, govern, or breach.

[Q&A pivot]: I'd love to dig into wherever this resonated.
```

## Highlight reel (~12 min)

| Slot | Vignette | Length | Why |
|---|---|---|---|
| 1 | V1 (abridged: registration + first agent answer + replacement-card animate) | ~4 min | Patient-facing AI hook |
| Bridge | "She filed a complaint about her sensor — let's see what happens behind the scenes." | 0:15 | |
| 2 | V4 (full hero beat: triage queue → drawer → Teams card → inject + watch autonomy live) | ~6 min | Hero differentiation — autonomous agent |
| Bridge | "And the same agent platform — different agent — runs the field team's day." | 0:15 | |
| 3 | V6 (Code App Knowledge tab → Teams 1:1 → SharePoint → M365 Copilot → tool fire from M365) | ~3 min | Closer / "extend everywhere" |
| Closer | The 3-bullet closer above | 1 min | |
| **Total** | | **~14 min** | (with a tight 12-min variant skipping bridges) |

V1 abridgement: skip insurance / training cards; keep registration + Patient Support agent + replacement-card animate.

## Cast of characters (light bios — Topic 9 deliverable)

**Note on names:** resolved from `data/names/people.md` (Topic 11 / Phase 0 name swap). The script's text references symbolic roles (`{patientName}`, `{hcpName}`) where applicable so future name swaps remain mechanical.

**Primary 4 (heroes):**
- **Maria Sullivan** — Patient. Newly diagnosed Type 1, registers in V1, files complaint that becomes V4's hero case.
- **Dr. Jacob Hancock, MD** — Endocrinologist. Maria's primary HCP. Drives V2; appears as referenced subject in V3 + V5.
- **Nicole Wagner** — Field Clinical Specialist. Manages the account where Dr. Hancock practices. Drives V3 + V5.
- **Quincy Brooks** — Quality Analyst. Drives V4. Receives Teams Adaptive Card, reviews triage, files MDR.

**Supporting 3:**
- **Lot 4421** — the recurring "bad lot" referenced in V4 lot-pattern story.
- **Continuum CGM G7 Pro** — the Sept-2026 product launch referenced in V5.
- **Adventurer Glucose Inc.** — the fictional competitor in V5 competitive briefs.

Photos: AI-generated medtech-appropriate headshots (Topic 2 imagery deliverable), committed under `sites/continuum-portal/public/img/cast/`.

## Demo Health pre-flight buttons (8 total)

Adds to Topic 6 Demo Health additions list:

| Button | What it does |
|---|---|
| `Pre-flight V1` | Verify Pages site green, Patient Support agent ping, registration form mock-submit smoke, anonymous web role accessible |
| `Pre-flight V2` | Verify HCP web role auth, roster query for `Dr. Hancock`, refill-due query, patient-needing-attention query |
| `Pre-flight V3` | Verify Code App green, FCS persona context loads, account 360 ping for primary account, agent docked panel ping |
| `Pre-flight V4` | Verify Quality nav loads, triage queue has ≥3 awaiting-review rows, MDR-clock < 24h on hero complaint, Teams channel reachable |
| `Pre-flight V5` | Verify Knowledge tab loads, all 7 Enablement docs present + < 8 days old, prompt-starter chips render |
| `Pre-flight V6` | Verify Teams app installed, SharePoint webpart present, M365 readiness checklist all checked |
| `Pre-flight Chained` | All 6 above + bridge state checks (V1→V2 patient row exists; V3→V4 complaint exists) |
| `Pre-flight Highlight Reel` | V1 + V4 + V6 subset of the above |

Each button triggers the respective `doctor.ps1 --vignette=V_` invocation behind the scenes (or `doctor.ps1 --mode=chained` / `--mode=highlight`); results stream into Demo Health's existing JSON output area.

## Audience track example

Inline tagging used on beats + Q&A:

```markdown
| 3 | New prescription | Click "New Prescription" → DemoFill → Submit | • `[BDM]` "Doctor signs the prescription, the patient's portal updates instantly, and the shipment lifecycle starts in Dataverse." • `[TDM]` "Notice this is a Code Site calling Web API — no Liquid templates. Permission check happened against the AuthenticatedHCP web role." | Drawer updates; stepper animates Created → Picked → InTransit | 1:00 |
```

## Recovery cookbook (cross-vignette themes)

The per-vignette recovery moves roll up into a cookbook with these chapters:

- **Network/connectivity hiccup** — Demo Health Errors panel deep-link, screen-share fallback to local cached state, Teams switchover.
- **Agent slow/timeout** — switch to pre-warmed docked panel, narrate via locked safe-fallback wording (Topic 8C).
- **Live-sim didn't fire** — manual "Inject" on Demo Health, narrate as intentional.
- **Adaptive Card didn't post** — open Teams channel directly, show prior cards.
- **Dataverse write failed** — quick "doctor" deep-link, confirm `cch_AgentStatus` did or didn't update, narrate honestly.
- **Persona switch broke** — refresh page (returns to last-good persona via localStorage), re-run pre-flight.

## "What this is NOT" appendix (drafted now)

```
This demo is NOT:
- A Microsoft product, sample, or reference architecture
- Endorsed or supported by Microsoft
- Built on Microsoft Cloud for Healthcare
- FDA-cleared, HIPAA-validated, or GxP-validated
- Built with real patient data — every name, MRN, NPI, lot, and complaint is synthetic
- A claim about how any specific medtech customer should design their implementation

This demo IS:
- A personal asset by Philip Urban (Microsoft Solution Engineer)
- MIT-licensed, AS-IS
- An illustration of how Power Platform + M365 capabilities can compose to support
  a Medtech persona arc end-to-end
```

(Mirrors the locked README disclaimer.)

## Updates to earlier locked decisions

- **Topic 6 Demo Health additions** — gains 8 pre-flight buttons (was 6 tiles + warm-up button + CS analytics iframe; now 6 tiles + warm-up + CS iframe + 8 pre-flight buttons).
- **Handoff §3.11 repo layout** — adds `docs/_planning/vignette-template.md` (the inner template extracted standalone for Phase 6 reuse).
- **Phase 6 (demo script & polish)** — scope sharpened: fill-in-the-blanks against the skeleton + write talk track per beat from Topic 1 click-paths + populate cast names from `data/names/people.md`.

## Deliverables to commit

1. **`docs/_planning/topic-09-demo-script.md`** ← this file
2. **`docs/demo-script.md` skeleton** — full file structure above with all 6 vignette sections stubbed using the inner template; intro/closer/appendices in place; talk track placeholders. Phase 6 fills text.
3. **`docs/_planning/vignette-template.md`** — extracted inner template, single source for Phase 6 to copy
4. **Cast-of-characters appendix** authored now (light bios above) — committed inside `docs/demo-script.md` Appendix A
5. **Topic 6 update** — Demo Health additions list gains the 8 pre-flight buttons (will fold into Topic 6's deliverable when authored)

## Out of scope (Phase 6 authoring work)

- Verbatim talk track per beat (we explicitly chose annotated bullets, not scripted sentences).
- Final cast names (depend on Phase 0 `data/names/people.md` population).
- Beat-by-beat click paths (already locked in Topic 1; Phase 6 transcribes them into the table).
- Q&A actual answers (drafted in Phase 6 against the locked governance/telemetry/agent decisions).
- Photo generation for cast (Topic 2 imagery deliverable).

## Open follow-ups (deferred — not blocking)

- **Per-audience customization beyond inline tags** (e.g., a CIO-flavored 5-min variant) — defer until requested.
- **Operator self-rehearsal flow** — could fold "rehearse mode" into Demo Health (autoclicks through pre-flight + each beat). Defer; manual rehearsal is fine.
- **Speaker-notes export to PowerPoint** — deferred per locked single-format decision; revisit only if a slide build emerges.

---

# Topic 9B — Per-vignette pre-flight, Q&A, recovery (locked)

**Locked on:** 2026-04-29

## Common pre-flight items (all 6 vignettes)

Every vignette's pre-flight checklist starts with these 4:

- [ ] Demo Health all green (Errors panel = 0; Heartbeat tile fresh < 12 min; Sparkline p95 latency < 3s)
- [ ] Last refresh < 24h (or click "Refresh now")
- [ ] Persona starting state matches vignette
- [ ] Browser tabs ready (close clutter; only the surfaces this vignette uses)

Then the vignette-specific items below.

## Per-vignette pre-flight (specific items)

### V1 — Patient onboarding & in-context support
- [ ] Persona = **Anonymous Visitor**
- [ ] Pages site V1 nav loads (Home / About / For HCPs / Support / Register)
- [ ] Patient Support agent ping returns < 2s (floating bubble pre-warmed)
- [ ] Registration form mock-submit smoke passed (`Pre-flight V1` button covers this)
- [ ] Hero rotation seeded for the run (refresh once if needed)

### V2 — HCP prescribing & patient roster
- [ ] Persona = **Dr. Jacob Hancock, MD** (Endocrinologist) — hero HCP per `data/names/people.md`
- [ ] Authenticated HCP web role active (auth-health indicator green)
- [ ] HCP daily-briefing returns ≥ 1 patient-needing-attention
- [ ] Roster contains the "Patients with anomalous readings" saved filter with ≥ 3 results (must include Maria Sullivan for V1→V2 chained-mode bridge)
- [ ] Refills-due query returns ≥ 2 rows

### V3 — Field Clinical Specialist account 360
- [ ] Persona = **Nicole Wagner** (FCS) — hero FCS per `data/names/people.md`
- [ ] Code App "My Day" loads with ≥ 3 planned visits
- [ ] FCS daily-briefing card pre-populated
- [ ] Primary account (Dr. Hancock's clinic) has ≥ 1 open service case
- [ ] Sample inventory shows ≥ 1 low-stock SKU
- [ ] Docked agent panel pre-warmed (one greeting turn already exchanged)

### V4 — Autonomous complaint triage & MDR drafting
- [ ] Persona = **Quincy Brooks** (Quality Analyst) — hero QA per `data/names/people.md`
- [ ] Quality nav visible in Code App
- [ ] Triage queue has ≥ 3 awaiting-review rows
- [ ] Hero complaint MDR-clock < 24h (locked Topic 4 default ~18h after refresh)
- [ ] Lot 4421 (or current "bad lot") has ≥ 3 complaints in last 7 days
- [ ] Teams Quality channel reachable (recent prior cards visible — last refresh re-posted at least one)
- [ ] "Inject complaint" button armed on Demo Health

### V5 — Employee enablement agent
- [ ] Persona = **Nicole** (FCS) or **Quincy** (Quality) depending on script flavor
- [ ] Knowledge tab loads
- [ ] All 7 Enablement subfolder docs present + `lastReviewed` < 8 days (Topic 8B doctor check)
- [ ] All 6 prompt-starter chips render
- [ ] Continuum Enablement agent ping < 2s
- [ ] Sample inventory + training catalog have headroom (so Order/Schedule actions don't hit `data_conflict`)

### V6 — Extend everywhere
- [ ] Persona = real signed-in user (operator narrates this difference per locked V6 decision)
- [ ] Continuum Enablement Teams app installed in operator's Teams
- [ ] SharePoint Training page loads with the agent webpart
- [ ] M365 Copilot agent picker shows "Continuum Enablement Agent"
- [ ] M365 readiness checklist all 6 boxes checked (locked Topic 8 doctor check)
- [ ] Power Platform admin tab open in another window for the governance closer

## Q&A inventory per vignette

For each question: the *question* is locked, the BDM/TDM tag is locked, the **answer-source pointer** is locked. Phase 6 expands the source pointer into actual answer text.

### V1 (5 questions)

| Q | Tag | Answer source |
|---|---|---|
| "How does the agent know who Maria is — is this real authentication?" | `[both]` | Topic 3 §AnonymousPatient + Topic 8 persona context contract |
| "Where does the AI run — is the patient data leaving the tenant?" | `[TDM]` | Topic 4 architecture summary + Topic 5 DLP scope |
| "Could a real medtech do this on PHI?" | `[BDM]` | "What this is NOT" appendix + handoff §3.1 compliance posture |
| "How long would this take to build for a customer?" | `[BDM]` | Phase plan summary (handoff §AGENTS.md phases) |
| "Why Power Pages and not a custom React app?" | `[TDM]` | Topic 8 system-prompt rationale + Topic 3 Pages auth posture |

### V2 (6 questions)

| Q | Tag | Answer source |
|---|---|---|
| "Is the HCP daily briefing pre-computed or live?" | `[TDM]` | Topic 8 `GetHCPDailyBriefing` tool spec |
| "Could the HCP edit the prescription after submitting?" | `[BDM]` | Topic 3 HCP web role write privileges |
| "How does this scale to 1000 HCPs?" | `[BDM]` | Topic 5 ME catalog + handoff §3.13 governance |
| "Is the shipment lifecycle real or simulated?" | `[both]` | Handoff §3.14 runtime independence + Topic 4 `cch_TunableShipmentStepSeconds` |
| "Where's the patient consent for the HCP to see this?" | `[both]` | "What this is NOT" appendix |
| "Could we plug in a real EHR?" | `[TDM]` | Out-of-scope; locked Dataverse + M365-only integration boundary |

### V3 (6 questions)

| Q | Tag | Answer source |
|---|---|---|
| "Does the email actually send, or is it a preview?" | `[both]` | Locked V3 decision: in-app preview only + Topic 8 `DraftEmailPreview` |
| "Who sends the Teams channel post — the rep or the bot?" | `[both]` | Topic 3 hybrid connection ownership + Topic 8 persona-in-header |
| "How does the Code App differ from a Power App canvas app?" | `[TDM]` | Locked surface decision (handoff §3.3) |
| "Could this work offline for a rep on the road?" | `[both]` | Out-of-scope (locked); honest answer |
| "How does the activity timeline get populated?" | `[TDM]` | Topic 6 telemetry + Topic 8 `cch_AgentToolWrapper` events |
| "Can the FCS see PHI for patients at their accounts?" | `[BDM]` | Topic 3 FieldRep org-level + UI-layer persona filter |

### V4 (7 questions — most-frequently-asked vignette)

| Q | Tag | Answer source |
|---|---|---|
| "Is the agent making the MDR call autonomously, or just suggesting?" | `[both]` | Topic 8 Quality Triage agent + analyst override workflow + locked `cch_AnalystOverride` |
| "How is 'MDR-reportable' actually decided?" | `[TDM]` | Topic 8 Quality Triage system-prompt + handoff §6.2 + `data/knowledge/Shared/regulatory-glossary.md` |
| "What's the audit trail when the agent edits a draft?" | `[BDM]` | Topic 3 persona attribution + Topic 5 audit log scope |
| "How fast can it really do this in production?" | `[both]` | Topic 6 telemetry sparkline + Topic 8 `cch_AgentToolWrapper` latency |
| "What if the agent gets it wrong?" | `[both]` | Topic 8 confirm-before-write + analyst override + escalate flow |
| "Is this FDA-validated?" | `[BDM]` | "What this is NOT" appendix |
| "Could we plug this into eMDR submission?" | `[TDM]` | Out-of-scope; locked architecture boundary |

### V5 (5 questions)

| Q | Tag | Answer source |
|---|---|---|
| "How fresh is the knowledge?" | `[both]` | Topic 8 freshness signaling + Topic 8B doctor `Knowledge` section |
| "What if the agent cites a wrong source?" | `[both]` | Topic 8 voice & tone (citation-led) + safe-fallback wording |
| "Where do these knowledge docs live?" | `[TDM]` | Topic 8B SharePoint subfolders + ACLs |
| "Could the rep update the knowledge from the Knowledge tab?" | `[BDM]` | Topic 8B ACLs (Write = DemoOperator only — answer is no, and why) |
| "How are tools authorized?" | `[TDM]` | Topic 8 confirm-before-write + Topic 3 SP via Graph |

### V6 (5 questions)

| Q | Tag | Answer source |
|---|---|---|
| "Is this the same agent across all four surfaces?" | `[both]` | Topic 8 single agent identity + Topic 8C system-prompt template |
| "How does persona differ outside the apps?" | `[both]` | Locked V6 narration: real signed-in user; Topic 8C system-prompt §3 |
| "What's the central governance story?" | `[both]` | Closer bullet 1 + Topic 5 DLP/ME/Audit |
| "How does this show up in Copilot Studio analytics?" | `[TDM]` | Topic 6 embedded CS analytics tile + Topic 8 telemetry mirror |
| "Could we publish this agent to a customer's tenant?" | `[both]` | Topic 8 M365 readiness checklist + handoff §3.14 install/upgrade |

## Recovery cookbook entries (vignette-specific)

Append to the 6 cross-vignette chapters in Topic 9 with these 6 vignette-specific entries:

| If… (vignette) | Then… |
|---|---|
| **V1** registration form validation hangs | Open Demo Health Errors panel; click failing client error deep-link; if still stuck, screen-share the form filled-in and narrate "as you'd expect, the row would land in `cch_Patient`" |
| **V2** roster filter returns 0 rows | Click "Refresh now" on Demo Health; if still 0, switch to Patient Support agent and ask "patients needing attention" — the agent will read the same query |
| **V3** Account 360 drawer slow to populate | Click on a different account first to warm the cache; reopen target account; narrate normal load time of <1s |
| **V4** "Inject complaint" button posts but no triage card appears | Confirm `cch_AgentStatus = Triaging`; if stuck, check Teams Quality channel directly — card likely posted but Code App didn't refresh; press refresh in the queue header |
| **V5** citations sidebar empty | Re-ask with different prompt-starter chip (knowledge docs may need warm-up); narrate "this is where the citations would render — let me show a recent screenshot" if still empty |
| **V6** M365 Copilot agent picker doesn't show our agent | Confirm M365 readiness checklist still all 6 boxes; restart M365 Copilot tab; fall back to SharePoint webpart for the same beat |

## `doctor.ps1` vignette-mode invocation spec

```
doctor.ps1                        # default: full doctor (read-only health check, all categories)
doctor.ps1 --vignette=V1          # subset: V1 pre-flight checklist items only
doctor.ps1 --vignette=V2          # ...etc V2 through V6
doctor.ps1 --mode=chained         # union of all 6 vignette pre-flights + bridge-state checks
doctor.ps1 --mode=highlight       # V1 + V4 + V6 pre-flights + alt-bridge checks
doctor.ps1 --json                 # JSON output (consumed by Demo Health pre-flight buttons)
doctor.ps1 --apply=false          # explicit no-op flag (default; locked doctor read-only)
```

Each vignette mode runs the corresponding subset of checks defined in this 9B section. Output JSON shape matches Topic 5 + Topic 6 doctor sections; Demo Health pre-flight buttons consume the JSON to render pass/fail dots per checklist item.

## Updates to earlier locked decisions

- **Topic 6 Demo Health additions** — pre-flight buttons (8) consume `doctor.ps1 --vignette=V_` JSON; per-checklist-item rendering joins the existing tile pattern.
- **Topic 5 doctor governance section** — runs unchanged on `--mode=full`; vignette modes skip it (governance posture doesn't change between demos).
- **Topic 8B doctor knowledge section** — runs on V5 vignette mode (knowledge freshness is V5's hot dependency).

## Topic 9B deliverables

1. **Append 9B section to `docs/_planning/topic-09-demo-script.md`** ✅ done
2. **`docs/demo-script.md` skeleton** — pre-populate per-vignette pre-flight checklists + Q&A inventory + recovery entries (Phase 6 fills the talk track + answer text)
3. **`doctor.ps1` vignette-mode invocation spec** above implemented in Phase 0 doctor authoring

## Final Topic 9 — what's now in scope vs. out of scope

**In scope (locked across 9 + 9B):** file shape · vignette inner template · intro/closer text · audience tags · highlight reel composition · 8 pre-flight buttons + checklists · cross-vignette recovery cookbook · 6 vignette-specific recovery entries · Q&A question inventory + answer-source pointers per vignette · cast bios (light) · doctor vignette-mode spec.

**Out of scope (Phase 6 authoring):** verbatim talk track · final cast names (depend on `data/names/people.md`) · Q&A actual answer text · click-path transcription from Topic 1 into the beat-by-beat tables · cast photos (Topic 2 imagery work).
