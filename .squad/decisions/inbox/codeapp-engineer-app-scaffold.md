# CodeApp-Engineer PR #1 — App scaffold: 3 cross-cutting decisions

> Inbox entry for Scribe to merge into `.squad/decisions.md`.
> Shape: Decided / Why / Alternatives considered / Affects — per Topic 10 lock.

---

## 2026-04-30 — `create-code-app` Power Platform skill unavailable in Copilot Cloud sandbox; fallback to direct Vite + React scaffold

**Decided:** `apps/field-companion/` is hand-scaffolded with `npm create vite@latest field-companion -- --template react-ts` + Fluent UI v9, **not** with the `create-code-app` Power Platform skill. Same path PR #19 took for the Pages site. The Power Platform integration layer (`@microsoft/power-apps` SDK, `power.config.json`, `pac code app push` wiring) is **deferred to a follow-up PR** and requires the skill + a live env.

**Why:** The `create-code-app` skill needs a live Power Platform environment + interactive `pac` auth + Code App service-on-tenant features that the Copilot Cloud agent sandbox doesn't have. Hand-scaffolded the Vite + React shell so component work, persona-store work, and a11y test infrastructure can land in parallel with the Power Platform wiring.

**Alternatives considered:**
- Block the PR until the skill is available → would block CodeApp-Engineer's first PR + delay every downstream component (`<AppShell/>`, `<PersonaSwitcher/>`, Demo Health) for no value.
- Hand-author `power.config.json` based on docs → high drift risk + we'd discover the actual schema mismatch only at first `pac code app push`. Better to land it via the skill once available.

**Affects:** Phase 3 scope. A follow-up CodeApp-Engineer PR (call it "PR #2" — Power Platform wiring) needs to: (1) run `create-code-app` against the existing scaffold, (2) merge the generated `power.config.json` + `@microsoft/power-apps` SDK + any required Vite plugin reconfiguration, (3) add `pac code app push` to deployment runbook.

---

## 2026-04-30 — Component duplication (Pages → CodeApp) accepted as interim; revisit if a third surface or first divergence forces it

**Decided:** `<ContinuumLogo/>` and `<DemoModeBanner/>` in `apps/field-companion/src/components/` are file-copies of the versions in `sites/continuum-portal/src/components/`, not consumed from a shared workspace package. Each copy carries a `// Copied from sites/continuum-portal/...` header line as the drift-detection signal.

**Why:** A shared workspace package (npm workspaces, pnpm workspaces, or a `packages/ui-shared` folder) adds build-graph complexity, shared build orchestration, and synchronized version bumps — all of which are heavy for the current 2-component shared surface. The file-copy + header-comment approach is the lowest-cost interim solution.

**Alternatives considered:**
- npm workspaces with `packages/ui-shared` → premium overhead for 2 components, would force re-scaffolding both sites + apps simultaneously.
- Git submodule → adds repo-management overhead + breaks Tier-1 working-directory assumptions.
- Component generator script (template-based) → slightly better than copy-paste but still doesn't catch drift.

**Affects:** Revisit when **either** (a) a third surface is added (Teams embed / SharePoint embed / standalone Storybook), **or** (b) the first divergence is forced by an environment-specific need. Whichever happens first triggers the workspace-package extraction. Until then, when one copy changes, manually sync the other or open a follow-up PR.

---

## 2026-04-30 — Persona starter-set hardcoded to 6 entries (Anonymous + 4 hero personas + Demo Operator); full population deferred to Dataverse-seed PR

**Decided:** `apps/field-companion/src/store/personaStore.ts` ships a `DEMO_PERSONAS` array of 6 entries: Anonymous Visitor, the 4 heroes from `data/names/people.md` (Maria Sullivan / Dr. Jacob Hancock / Nicole Wagner / Quincy Brooks), and Demo Operator. The Topic 1 lock calls for "full-population searchable" but the seed data + `data/names/people.md`-loader don't exist yet.

**Why:** The persona switcher is a Topic 1 must-have on every screen, including for the Phase 3 Demo Health stub. Blocking the scaffold until full-population seed + Dataverse loader exists is unnecessary because (a) the 6-entry starter set exercises all the UX patterns (search, active state, role-gated nav, store hydration), (b) the heroes are the primary demo personas anyway, and (c) the loader will replace the array — it's a clean swap, not a refactor.

**Alternatives considered:**
- Block the scaffold on full-population data → blocks `<AppShell/>` + `<PersonaSwitcher/>` + a11y test scaffold + Demo Health for everyone else for at least a phase.
- Hardcode all 50 patient + 20 HCP + 10 FCS + 5 QA names from `people.md` → still hardcoded; full-population belongs in Dataverse so the demo can show real Dataverse-backed patient lookups, not array filtering.

**Operator follow-up:** A follow-up CodeApp-Engineer PR (after Dataverse-Engineer ships `data/seed.ts` and the Web API loader patterns are established) replaces the hardcoded `DEMO_PERSONAS` constant with a Dataverse-backed loader that pages through `cch_patient`, `cch_hcp`-equivalent contacts, and field rep system users.

**Affects:** Phase 3 (CodeApp persona store), Phase 1 tail-end (seed data + name population), the persona switcher's "full-population searchable" Topic 1 lock (deferred not abandoned). Tests in `__tests__/PersonaSwitcher.test.tsx` and `__tests__/PersonaSwitchAnnouncer.test.tsx` assert against the 6-entry starter set; the swap to loader-backed data should preserve the 6 IDs (Anonymous + 4 heroes + Demo Operator) for test stability.

---
