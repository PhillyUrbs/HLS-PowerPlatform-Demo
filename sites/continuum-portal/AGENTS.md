# AGENTS.md — sites/continuum-portal/

**Owner role(s):** Pages-Engineer (primary) · Tester (E2E reviews) · CodeApp-Engineer (shared component co-owner)

## Scope

The Power Pages Code Site (React SPA + Fluent UI v9) hosting V1 (patient onboarding +
in-context support) and V2 (HCP prescribing + roster). Anonymous + AuthenticatedPatient
+ AuthenticatedHCP web roles. Pages auth via Entra ID (single demo super user).

## House rules

- Fluent UI v9 only.
- `<DemoModeBanner/>` mounted at site shell — present on every page.
- `audit-permissions` Tier-1 must be clean before merge (Topic 3 lock).
- Web role + table-permission YAML co-located with the React route that uses it,
  not pooled centrally.
- Floating-bubble agent uses `<AgentChatHost size="floatingBubble">`.
- Anonymous Patient web role: create-only on `cch_Patient`, no reads on any custom
  table (Topic 3 lock).
- AuthenticatedHCP: relationship-scoped on Patients-where-PrimaryHCP=me.
- AuthenticatedPatient: self + record-owner scope on Patient; relationship reads on
  Prescription / Shipment / Complaint / Device.

## Skills to use

- `create-site` for scaffold
- `setup-auth` for Entra ID
- `create-webroles` for web role authoring
- `integrate-webapi` for Dataverse calls
- `audit-permissions` (run before every PR)
- `add-seo` for V1 public area
- `deploy-site` and `activate-site`
- `test-site` for runtime verification

## Hand-off rules

- Hand off to **CodeApp-Engineer** for shared-component-library changes (CodeApp is
  primary; Pages reviews; Lead arbitrates per cross-cutting table).
- Hand off to **Dataverse-Engineer** when a route needs schema additions.
- Hand off to **Agent-Builder** for floating-bubble persona-context contracts.
- Hand off to **Lead** if Entra app reg provisioning is missing.

## Definition of done (per PR)

- [ ] `audit-permissions` Tier-1 green (this is the gating check for Pages PRs)
- [ ] Tier-1 a11y axe green
- [ ] Web role + table-permission YAML present for any new route
- [ ] `<DemoModeBanner/>` not removed
- [ ] `decisions.md` entry if shared component contract changed
