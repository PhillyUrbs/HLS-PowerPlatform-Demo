# AGENTS.md — agents/

**Owner role(s):** Agent-Builder

## Scope

The 3 Copilot Studio agents (Patient Support, Quality Triage, Continuum Enablement),
each in its own subfolder with the export, `spec.md`, `system-prompt.md`, avatar SVG,
and (for Enablement) `m365-readiness.md`. Authored against the locked Topic 8 + 8B + 8C
contracts.

## House rules

- Per-agent `spec.md` and `system-prompt.md` co-located with the export — never in
  `docs/`.
- `system-prompt.md` must contain all 6 H2 sections (Identity, Voice & Tone, Persona
  context contract, Tool catalog, Knowledge sources, Safety & fallback) — Tier-1 lints.
- Standard tool envelope honored: `{success, data, displayMessage, citations[],
  correlationId, errorCode?}`. Error codes from the 10-code enum.
- Safe-fallback wording matches Topic 8C verbatim — **do not paraphrase**.
- Confirm-before-write on every write tool. Read tools fire silently.
- Patient Support uses persona-router topic + per-persona groups (Patient / HCP / FCS
  / Anonymous). One agent identity, four personas.
- Quality Triage triggered by `cch_TriggerQualityTriage` wrapper flow only — never
  direct Dataverse trigger.
- Enablement agent = single persona (real signed-in user on M365/Teams/SP). M365
  readiness checklist all 6 boxes before V6 publish.
- **Anonymous browser users never read from SharePoint directly**; the agent reads as
  SP identity and surfaces answers via Direct Line. Do not "fix" Topic 8B's
  `Anonymous: none` ACL. (Topic 11 §C8.)

## Skills to use

- `add-mcscopilot` for any Code App embedding contract changes

## Hand-off rules

- Hand off to **Flows-Engineer** for new tool flows or envelope-schema changes.
- Hand off to **Dataverse-Engineer** if a topic needs new persona-attribution coverage.
- Hand off to **CodeApp-Engineer / Pages-Engineer** for `<AgentChatHost/>` prop changes.
- Receive **Scribe** voice & tone updates (Scribe owns `docs/voice-and-tone.md`).

## Definition of done (per PR)

- [ ] All 6 system-prompt sections present (Tier-1 lint)
- [ ] Standard envelope honored on all tool calls
- [ ] Safe-fallback wording verbatim
- [ ] M365 readiness checklist updated (Enablement only)
- [ ] `decisions.md` entry if voice / topic structure changed
