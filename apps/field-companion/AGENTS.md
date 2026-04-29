# AGENTS.md — apps/field-companion/

**Owner role(s):** CodeApp-Engineer (primary) · Tester (E2E reviews) · Pages-Engineer (shared component co-owner)

## Scope

The Power Apps Code App (React + Vite + Fluent UI v9) hosting V3 (FCS account 360),
V4 (Quality triage workspace), V5 (Knowledge tab), and the Demo Health operator page.
Built per Topic 8C `<AgentChatHost/>` contract; per Topic 6 telemetry SDK; per Topic 7
a11y AA target.

## House rules

- Fluent UI v9 only — no v8, no third-party design systems.
- Light theme only (Topic 7 lock).
- `<DemoModeBanner/>` mounted at AppShell — present on every screen, dismissible per
  session, returns on refresh.
- Telemetry SDK auto-imports persona context from the persona overlay store; callers
  never pass it explicitly.
- `<AgentChatHost/>` is the only way to embed an agent (3 size variants).
- Prompt-starter chips read from `src/config/promptStarters.ts` per locked Topic 8B.
- Demo Health page nav restricted to `DemoOperator` role (Topic 3) — never visible
  to personas.
- `CitationsRenderer mode="popover"` for in-panel agents; `mode="sidebar"` only for
  V5 Knowledge tab.

## Skills to use

- `create-code-app` for scaffold
- `add-dataverse` for typed services
- `add-office365` / `add-teams` / `add-onedrive` / `add-sharepoint` for connectors
- `add-mcscopilot` for agent embedding contracts
- `deploy` for Code App publish

## Hand-off rules

- Hand off to **Pages-Engineer** for shared-component-library changes (CodeApp is
  primary; Pages reviews; Lead arbitrates per cross-cutting table).
- Hand off to **Flows-Engineer** when Demo Health needs a new telemetry query or
  a new pre-flight signal.
- Hand off to **Tester** when `doctor.ps1` JSON contract needs to change.
- Receive **Agent-Builder** spec changes that require new prop shapes.

## Definition of done (per PR)

- [ ] Tier-1 a11y axe green
- [ ] Tier-1 ESLint + jsx-a11y green
- [ ] Telemetry events dispatched for new beats / errors / persona switches
- [ ] Demo Health additions hooked to `doctor.ps1 --vignette=V_` JSON
- [ ] `<DemoModeBanner/>` not removed
- [ ] `decisions.md` entry if shared component contract changed
