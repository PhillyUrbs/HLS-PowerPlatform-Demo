# Topic 3 — Permission matrix (locked)

**Locked on:** 2026-04-29
**Scenario layer:** 🟡 **Hybrid** — *Structure agnostic* (3-table matrix shape, hybrid SP+interactive ownership pattern, `audit-permissions` Tier-1 gate, `ServicePrincipal`+`DemoOperator` bespoke role pattern, no-FLS posture). *Content scenario-specific* (the 4 persona security roles + 3 web roles + per-role scoping reflect Medtech personas). Forking: keep matrix shape + bespoke roles; redo persona-driven roles.

## Framing

- The **persona overlay is UI-only** — every Dataverse write actually originates from the SP (or the demo super user). `cch_CreatedByPersona` is metadata, **not** a security boundary.
- Only **two real Dataverse callers** exist: the **Service Principal** (most flows + agent tools + scheduled jobs) and the **demo super user** (interactive Code App + Pages writes).
- The **only real access-control surface for portal users** is **Pages table permissions** mapped to web roles. Dataverse-side scoping for the four "persona" security roles is loose by design — UI-level filtering does the rest.
- `audit-permissions` skill is the verification step, gated to PR-time.

## Decisions

| Area | Decision | Rationale |
|---|---|---|
| **Matrix format** | Single `docs/permissions.md` with three tables: Dataverse role × table, Pages web role × table, connector × default owner | One grep-able source of truth; diffs cleanly in PRs; reviewers see whole picture |
| **Dataverse role scope** | Org-level on all four security roles (`PatientPortal`, `HCPPortal`, `FieldRep`, `QualityAnalyst`) for primary tables. UI does persona filtering using `primaryAccountId` / `primaryPatientId` from the persona overlay | Matches the "one super user + SP" reality; no BU traps; persona display filtering is already a React-layer concern |
| **AuthenticatedPatient web role** | Self + record-owner scope on Patient; relationship-scoped reads on Prescription / Shipment / Complaint / Device tied to the Patient | Matches V1 self-service beat; protects synthetic-PHI optics; enables V1 shipment-stepper bridge |
| **AuthenticatedHCP web role** | Relationship-scoped on Patients-where-PrimaryHCP=me; create on Prescription; read on tied lifecycle rows (Shipment / Complaint / Device); no write on Patient core profile | Matches V2 hero "my patients needing attention" beat; clinical attribution stays clean |
| **AnonymousPatient web role** | Create-only on Patient (registration submit); no reads on any custom table; static Pages content is JSX | Minimum surface for V1 pre-registration beats; no synthetic-PHI exposure to the public web |
| **Service Principal role assignment** | Bespoke `ServicePrincipal` Dataverse security role, org-scoped on every table it writes (primary tables + persona-attribution columns + flow-only tables: `cch_DemoAnchor`, `cch_LiveSimSetting`, `cch_DeploymentHistory`, `cch_TestRun`-tagged rows) | Single source of truth for what the SP actually needs; cleaner audit story than reusing one of the four persona roles |
| **Demo infrastructure tables access** | Bespoke `DemoOperator` Dataverse security role; assigned to super user(s) + SP only. Personas don't see Demo Health page in their nav | Demo Health is for demo operators, not personas; conflating with `FieldRep` would muddy the story |
| **Field-Level Security** | None — keep all columns visible per role; rely on synthetic-data banner | Avoids Phase-1 setup cost, audit-permissions surface area, and demo-time confusion. Revisit only if a TDM specifically asks "how would you protect MRN?" |
| **`audit-permissions` cadence** | Tier-1 GitHub Actions step on every PR that touches `sites/continuum-portal/**` or Pages table-permission YAML | Catches drift before review; fits the existing Tier-1 pattern of fast static checks |

## Deliverables to commit

1. **`docs/permissions.md`** — canonical matrix with three tables:
   - Dataverse security role × table (privileges: C/R/U/D/Append/AppendTo/Share + scope)
   - Pages web role × table (privileges + scope: Global / Contact / Account / Self / Parent)
   - Connector × default owner (SP vs interactive identity, per locked §3.7 hybrid)
2. **`solutions/ContinuumHealthDemo/src/.../SecurityRoles/ServicePrincipal.xml`** — committed in the solution.
3. **`solutions/ContinuumHealthDemo/src/.../SecurityRoles/DemoOperator.xml`** — committed in the solution.
4. **Role-assignment matrix in `docs/install.md`** — which super user / alternate gets which roles. Default: every super user gets `PatientPortal` + `HCPPortal` + `FieldRep` + `QualityAnalyst` + `DemoOperator` (so any alternate can drive any vignette). SP gets `ServicePrincipal` + `DemoOperator`.
5. **Tier-1 GitHub Actions step** that runs `audit-permissions` on Pages-touching PRs (in `.github/workflows/ci-tier1.yml`).
6. **Mermaid "who-can-touch-what" diagram** in `docs/architecture.md` — useful for the V6 governance closer.

## Updates to earlier locked decisions

- **Handoff §4.4 Security roles** grows from 4 to **6**: `PatientPortal`, `HCPPortal`, `FieldRep`, `QualityAnalyst`, **`ServicePrincipal`** (new), **`DemoOperator`** (new).
- **Handoff §3.13 Governance recommendations** — add `audit-permissions` as a Tier-1 gate (was implied by the house rule; now an actual workflow step).
- **Handoff §3.16 Tier 1** — append: "audit-permissions on Pages PRs".
- **Handoff §4 Custom tables** — add **`cch_LiveSimSetting`** (singleton) as already noted; confirm it lands in the `DemoOperator` scope.

## Open follow-ups (deferred — not blocking)

- **Per-cell privilege fill-in** for `docs/permissions.md` — done at deliverable time, not now.
- **Connection-reference inventory** (the connector × owner table rows) — overlaps with **Topic 4: Environment variables** and **Topic 8: per-agent topic & tool design**. Will cross-reference.
- **Adaptive Card "post-as" identity audit** for V3/V4/V5/V6 channel posts — already locked as SP + persona-in-header; verify in `audit-permissions` v2 if/when the skill grows beyond Pages.
