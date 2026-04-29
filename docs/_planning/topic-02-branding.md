# Topic 2 — Branding & visual identity (locked)

**Locked on:** 2026-04-28
**Scenario layer:** 🟡 **Hybrid** — *Structure agnostic* (logo+wordmark approach, palette-token-in-`theme.ts`, `<DemoModeBanner/>`, agent-avatar family pattern, light-mode-only). *Content scenario-specific* (palette hex values, company name, agent avatar designs, hero imagery). Forking: keep structure, re-pick palette + name + imagery.
**Supersedes:** the placeholder line in `handoff-2026-04-28.md` §3.1 ("Branding: Default — Contoso Continuum Health, clinical blue/teal palette. Detailed branding is **Topic 2 — still open**.")

## Decisions

| Area | Decision | Rationale |
|---|---|---|
| **Logo** | Wordmark + simple geometric mark, hand-authored SVG, exposed as `<ContinuumLogo/>` in the shared component library | Zero licensing risk, scales perfectly, recolors via CSS variable, lives in repo |
| **Palette** | Teal-forward — primary teal `#0E7C86`, supporting cobalt, neutral slate. Fluent UI v9 brand ramp derived from the primary | Distinct from default Microsoft chrome (so screenshots don't blur into product UI), reads as medtech, AA-contrast |
| **Typography** | Segoe UI Variable everywhere — Code App, Pages, Teams Adaptive Cards, Word/PDF grounding docs | Zero licensing, ships with Fluent v9 + Windows + Office, perfectly consistent across surfaces |
| **Imagery (V1 public area)** | AI-generated medtech imagery (Designer / DALL·E), committed as static SVG/PNG under `sites/continuum-portal/public/img/`. Generate once; never refetch at runtime | Controllable, on-brand, no licensing/attribution overhead, regeneratable if palette shifts |
| **Demo Mode banner** | Slim full-width top strip, brand-tinted, **dismissible-per-session** (returns on every page refresh / persona switch / new tab) | Always visible without dominating; auto-returns so demo viewers never see a screen without it; doesn't intrude on screenshots |
| **Agent avatars** | Three distinct geometric SVG marks sharing the Continuum palette + a common "spark" motif. One per agent under `agents/<name>/avatar.svg` | Communicates "family of agents, same governance" (the V6 thesis) while keeping each instantly recognizable in Teams cards / M365 Copilot picker |
| **Dark mode** | Light only (Fluent v9 light theme). No system-follow, no toggle | Healthcare apps are overwhelmingly light-themed in the real world; one theme to design / screenshot / grounding-doc against; zero ROI for a demo |

## Deliverables to commit (during Phase 2 setup, before any vignette work)

1. **`docs/branding.md`** — single source of truth: palette tokens (primary, accent, status, neutrals), typography scale, voice & tone summary, do/don't, banner spec, logo usage, agent-avatar usage, footer disclaimer wording.
2. **Fluent v9 brand ramp tokens** in a shared `theme.ts` (referenced by both `apps/field-companion/` and `sites/continuum-portal/`). Single source so Code App + Pages can't drift.
3. **`<ContinuumLogo/>` and `<DemoModeBanner/>`** as the *first commits* in the shared component library — every later vignette composes against them.
4. **Three agent-avatar SVGs** under `agents/patient-support/avatar.svg`, `agents/quality-analyst/avatar.svg`, `agents/employee-enablement/avatar.svg`.
5. **Hero imagery** generated and committed under `sites/continuum-portal/public/img/` (V1 home, About CGM, For HCPs, Support).
6. **Voice & tone short-doc** (`docs/voice-and-tone.md` or a section in `branding.md`) — how the Continuum brand "talks". Per-agent voice refinement deferred to Topic 8.
7. **Microsoft-fictitious-disclaimer footer wording** — one canonical string used in Pages footer, app shell footer, and every grounding doc.

## Updates to earlier locked decisions

- **Reusable component library (handoff §5)** grows from 17 to 19:
  - Add #18 `<ContinuumLogo/>` — first introduced Phase 2, used by AppShell + Pages + grounding docs
  - Add #19 `<DemoModeBanner/>` — first introduced Phase 2, used everywhere
  These will be reflected when the Phase-2 charter is drafted.

- **Sentence in handoff §3.1** ("Branding: Default — Contoso Continuum Health, clinical blue/teal palette. Detailed branding is **Topic 2 — still open**.") is now superseded by this document.

## Open follow-ups (deferred — not blocking)

- **Per-agent voice differentiation** (Patient Support warm/reassuring vs. Quality Triage clinical/precise vs. Continuum Enablement upbeat/expert) — Topic 8.
- **Image-generation prompts** for V1 hero imagery — captured at branding deliverable time, not now.
- **Exact Adaptive Card color tokens** for severity borders — Topic 3 (permission matrix) or Topic 5 (governance) when we walk the V4 surface in detail.
