# Topic 7 — A11y & localization (locked)

**Locked on:** 2026-04-29
**Scenario layer:** 🟢 **Scenario-agnostic** — WCAG 2.1 AA target, axe-core in Vitest (Tier 1) + Playwright (Tier 3), persona-switch announcer pattern, reduced-motion behavior, 200% zoom support, en-US-only stance. **One scenario-specific item:** clinical units locked to mg/dL (CGM context). Forking to non-Medtech: swap clinical units (or drop the unit lock entirely if not clinical-data-driven).

## Framing

- Locked **AA target** in handoff §3.3; this topic turns it into a checklist + CI gate.
- Locked **light theme only** (Topic 2) → contrast verification only against the light Fluent v9 brand ramp.
- Locked **subtle live-update animations** (handoff §3.3) → must respect `prefers-reduced-motion`.
- Locked **Demo Mode banner on every screen** (Topic 2) → must use proper landmark role (`role="banner"` / `<header>`) without breaking the page's primary banner.
- Locked **persona overlay always visible** (handoff §3.4) → custom widget needs explicit screen-reader announcement on switch.

## Decisions

### Accessibility

| Area | Decision | Rationale |
|---|---|---|
| **Target** | WCAG 2.1 AA on every component we author; rely on Fluent v9 defaults elsewhere. Self-attest in `docs/accessibility.md` (no formal third-party audit) | Matches locked §3.3 |
| **Coverage areas (all eight enabled)** | Keyboard navigation · Screen reader semantics · Color-not-the-only-signal · Reduced-motion · Form labelling + error announcements · Persona-switch announcement · Palette contrast verification · Text-resize to 200% | Comprehensive on the surface we author; nothing punted |
| **Enforcement** | axe-core in Vitest (component-level) + axe-core in Playwright (E2E per locked §3.17, one per vignette). **Tier-1 fails on AA violations** | Catches a11y rot at PR time; matches the existing Tier-1 hard-gate posture for lint/types |
| **Doctor coverage** | Doctor reads the last CI run summary and reports `a11y: pass | N issues | unknown` (info only) | Honors locked "doctor never changes data" rule; gives the operator a one-line pre-demo signal |

### Localization

| Area | Decision | Rationale |
|---|---|---|
| **Scope** | **English-only (en-US).** No i18n scaffolding. Strings hard-coded in JSX | Demo audience is North America; demo language is English. Honest, cheapest, no half-broken i18n shell |
| **Date/time rendering** | All in-app dates/times rendered in `cch_TunableTimezone` (Topic 4 default `Eastern Standard Time`); explicit TZ suffix on dashboards | Prevents "why does the demo say 5am?" confusion when running from PST/UTC |
| **Clinical units** | Glucose **mg/dL only** (US). No mmol/L. Single utility, single talking point | Medtech audience expectation in US |
| **Synthetic data locale** | Faker locale **fixed to `en_US`** | Phone numbers, addresses, MRN format follow US conventions only |
| **Currency** | **USD** (`$`); no `Intl.NumberFormat` locale negotiation | Sample-order pricing tiles get a single fixed format |
| **Grounding-doc date format** | Locked to **US long form** (`April 29, 2026`) for `{{today}}` substitutions | Templated-doc weekly republish flow (locked §3.9) needs a single deterministic format |

### Intentionally NOT in scope

- **AAA conformance** (would require re-tinting the locked teal palette).
- **RTL layouts** (no audience for the demo).
- **Captions/transcripts** (no audio in demo).
- **i18n string externalization / translation-ready scaffolding** (would imply false promises; revisit if the demo ever ships in a non-en locale).
- **Live axe in doctor** (slow; CI summary read is sufficient pre-demo signal).

## Component-library a11y additions (Phase 2)

Three additions to the shared component library beyond the 19 locked components (Topics 2 + 5 → 19):

| # | Component / utility | Purpose |
|---|---|---|
| 20 | **`<ReducedMotionProvider/>`** | Reads `@media (prefers-reduced-motion)`; provides hook used by `<LiveUpdateRow/>` and `<LifecycleStepper/>` to skip transitions |
| 21 | **`<PersonaSwitchAnnouncer/>`** | Off-screen `aria-live="polite"` region; emits "Now acting as <name>, <role>" on every persona switch |
| 22 | **`sr-only` utility class** | Standard screen-reader-only text class (visually hidden, AT-readable) for icon-only chips and buttons |

These bring the component library to **22 components**.

## CI wiring spec

### Tier 1 (PR-time, locked §3.16)

- **eslint-plugin-jsx-a11y** added to the existing ESLint config (already in lint pass; zero new step).
- **Vitest + axe-core** new step `npm run test:a11y` per app/site:
  - Runs against rendered components for the canonical happy paths of every shared component.
  - Fails on AA violations.
  - Excluded rules (with justification documented in `docs/accessibility.md`): none at lock time; any future exclusion requires a PR justification.

### Tier 3 (nightly, locked §3.17)

- **Playwright + axe-playwright** scans one E2E test per vignette against the deployed `pp-demo-ci` env after the smoke suite.
- Fails the nightly run on AA violations (matches Tier-1 posture).
- Surfaces results in the existing nightly HTML summary.

### Tier 1 also gains

- A static check that every interactive component imports from the shared library or applies `aria-label` (catches custom buttons that bypass Fluent).

## Persona-switch announcement spec

```ts
// In persona overlay store
function switchPersona(next: Persona) {
  const message = `Now acting as ${next.name}, ${next.title}`;
  // PersonaSwitchAnnouncer reads from the store and writes message into aria-live region
  setActivePersona(next);
  emitTelemetry({ category: 'PersonaSwitch', eventName: 'overlay.switched', payload: { from: prev.id, to: next.id, surface } });
}
```

- One announcement per switch (debounced if a rapid sequence happens).
- Anonymous Visitor switch: `"Now browsing as Anonymous Visitor"`.

## Reduced-motion behavior

| Animation | Reduced-motion fallback |
|---|---|
| Live-update row highlight + slide-in | Background flash for 100ms only; no slide |
| Lifecycle stepper advance | Instant state change; no transition |
| Drawer open/close | Instant; no slide |
| Adaptive Card delivery toast | Static appear; auto-dismiss |
| `<DemoModeBanner/>` (no animation locked) | n/a |

## Color-contrast verification

One-time check at branding lock (Topic 2 deliverable):

| Pair | Ratio target | Status |
|---|---|---|
| Body text `#1A1A1A` on background `#FFFFFF` | 4.5:1 (AA normal) | passes (15.3:1) |
| Brand teal `#0E7C86` text on white | 4.5:1 | **verify at branding deliverable** (target ≥ 4.5) |
| Brand teal `#0E7C86` background + white text | 4.5:1 | **verify** |
| Status chip Severity-Critical | 3:1 (AA non-text + AA large text) | verify |
| Status chip Severity-High / Medium / Low | 3:1 | verify |
| MDR clock chip color states | 3:1 | verify |
| Demo Mode banner text on brand-tinted strip | 4.5:1 | verify |

Verification is a one-time pass run during Phase 2 branding-deliverable commit; results recorded in `docs/branding.md` § Contrast.

## Updates to earlier locked decisions

- **Handoff §3.3** — confirmed; this topic adds the enforcement mechanism.
- **Handoff §3.16 Tier 1** — gains `npm run test:a11y` (axe-in-Vitest) and the static interactive-component check.
- **Handoff §3.17 Tier 3** — gains axe-playwright scan per vignette.
- **Component library** — grows from 19 to **22** (`<ReducedMotionProvider/>`, `<PersonaSwitchAnnouncer/>`, `sr-only`).
- **Topic 4 env vars** — `cch_TunableTimezone` already exists; no new env vars.
- **Topic 6 telemetry** — persona-switch announcement co-emits a telemetry event (already in scope under `PersonaSwitch` category).
- **Topic 2 branding** — `docs/branding.md` deliverable gains a § Contrast section with the verified ratios.

## Deliverables to commit

1. **`docs/_planning/topic-07-a11y-l10n.md`** ← this file
2. **`docs/accessibility.md`** — self-attestation + AA target + custom-component checklist + known limits + axe rule baseline + reduced-motion behavior table + persona-switch announcement spec
3. **`docs/localization.md`** — short doc: en-US-only rationale + TZ handling + units + Faker locale + currency + grounding-doc date format
4. **Tier-1 wiring spec** included in the topic doc above; implementation lands in `.github/workflows/ci-tier1.yml` + `apps/*/package.json` `test:a11y` script
5. **Tier-3 axe-playwright wiring** lands in the nightly workflow in Phase 0
6. **Component library additions** scheduled for Phase 2 (`<ReducedMotionProvider/>`, `<PersonaSwitchAnnouncer/>`, `sr-only`)

## Open follow-ups (deferred — not blocking)

- **Per-component a11y test fixtures** — written when each component lands in Phase 2.
- **Manual screen-reader smoke** (NVDA / VoiceOver) — operator runs once per milestone tag; not gated.
- **Glossary/voice consistency for screen-reader text** — folds into Topic 8 (per-agent topic & tool design) voice-and-tone work.
- **Translation-ready scaffolding** — explicitly out of scope; revisit only if a non-en demo is ever needed.
