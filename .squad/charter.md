# Squad Team Charter — HLS Power Platform Demo

> **Authoritative team-wide charter.** Each role's individual charter lives at `.squad/agents/<role>/charter.md`. This doc covers the team-wide patterns: roster, conflict resolution, cross-cutting artifact ownership, phase gating, ceremonies pointer.

**Locked:** 2026-04-29 (Topic 10 + 10B in `docs/_planning/`)
**Roster size:** 9 roles (no additions without explicit user approval)

## Roster

| Role | Charter | Primary surface |
|---|---|---|
| **Lead** | [.squad/agents/lead/charter.md](agents/lead/charter.md) | Repo-wide; installer; phase gating |
| **Dataverse-Engineer** | [.squad/agents/dataverse-engineer/charter.md](agents/dataverse-engineer/charter.md) | `solutions/`, `data/` |
| **Pages-Engineer** | [.squad/agents/pages-engineer/charter.md](agents/pages-engineer/charter.md) | `sites/continuum-portal/` |
| **CodeApp-Engineer** | [.squad/agents/codeapp-engineer/charter.md](agents/codeapp-engineer/charter.md) | `apps/field-companion/` |
| **Flows-Engineer** | [.squad/agents/flows-engineer/charter.md](agents/flows-engineer/charter.md) | flows in solution |
| **Agent-Builder** | [.squad/agents/agent-builder/charter.md](agents/agent-builder/charter.md) | `agents/*/` |
| **Governance** | [.squad/agents/governance/charter.md](agents/governance/charter.md) | `scripts/governance/`, governance docs |
| **Tester** | [.squad/agents/tester/charter.md](agents/tester/charter.md) | `scripts/doctor.ps1`, `.github/workflows/`, test files everywhere (embedded) |
| **Scribe** | [.squad/agents/scribe/charter.md](agents/scribe/charter.md) | `.squad/decisions.md`, `data/knowledge/` content, `docs/demo-script.md` Phase-6 prose |

## Conflict resolution playbook (4 steps)

When two roles disagree on a contract:

1. **Check `.squad/decisions.md`** for prior lock. If found, follow it. Done.
2. **Consumer wins by default.** The role *consuming* the contract proposes the shape; the role *producing* it adapts.
   *Example:* if CodeApp-Engineer (consumer of `<AgentChatHost/>` `onToolCall` callback) wants shape A, and Flows-Engineer (producer of the upstream tool envelope) wants shape B that's incompatible at the React boundary, CodeApp's shape wins; Flows-Engineer adapts the envelope mapper.
3. **If still disagreement after step 2,** escalate to **Lead** with a 1-paragraph summary from each role. Lead decides.
4. **Every conflict resolution is a `decisions.md` entry,** authored by Scribe with the standard entry shape. Includes the resolution + which option each role originally preferred + why.

**Locked exception:** Lead's own decisions are escalated to the human (the user) since there's no Lead-of-Lead role.

## Cross-cutting ownership table (6 artifacts)

For artifacts that don't have a clean single-role owner. Per Topic 10B + Topic 11 §C6 update.

| Artifact | Primary owner (writes) | Secondary (reviews) | Arbiter |
|---|---|---|---|
| **Shared component library** (24 components in `apps/.../components/` and `sites/.../components/`) | CodeApp-Engineer | Pages-Engineer | Lead |
| **Knowledge `.md` prose** (15 docs under `data/knowledge/`) | Scribe | Agent-Builder reviews per-agent subfolder; Dataverse-Engineer reviews structural drift from skeleton | Lead |
| **Demo script `.md` Phase-6 prose** | Scribe (drafts talk track + Q&A answers) | Lead reviews vs. architecture; CodeApp/Pages-Engineer review per-vignette accuracy | Lead |
| **Adaptive Card JSON visual content** (5 templates) | Flows-Engineer (structure, data binding) | Pages+CodeApp (visual contract: brand teal, persona-in-header partial, status colors) | Lead |
| **Voice & tone short-doc** (`docs/voice-and-tone.md`) | Scribe | Agent-Builder per-agent rows from Topic 8 | Lead |
| **Demo Health page** (in `apps/field-companion/`) | CodeApp-Engineer (host + tile rendering) | Tester (doctor JSON contract); Governance (governance posture data) | Lead |

**Notes:**
- "Primary owner" makes commits; PR review-required from "Secondary" before merge.
- "Arbiter" is invoked only if Primary/Secondary deadlock per the conflict playbook.
- Cross-cutting changes still get a `decisions.md` entry per the locked decisions-log policy.

## Phase gating

- Current phase tracked in [`.squad/phase.json`](phase.json).
- Phase transitions: Lead PRs `phase.json` + Scribe records the transition in `decisions.md`.
- Tier-1 lints `currentPhase` value vs. file changes (warning only — soft gate, not blocking).
- Phase 0 (current) → Phase 1 → 2/3/4 (parallel after 1) → 5 (depends on 1 + relevant flows) → 6.

## Ceremonies

- **Design Review** — auto, before multi-agent tasks involving 2+ agents modifying shared systems. Facilitator: Lead. See [.squad/ceremonies.md](ceremonies.md).
- **Retrospective** — auto, after work. See [.squad/ceremonies.md](ceremonies.md).

## Operating principles (cross-role)

1. **Phase-gated.** Don't start Phase N+1 until N's verification checklist passes and human approves.
2. **Use existing skills.** See `.github/copilot-instructions.md` skills table. Don't hand-write what a skill can generate.
3. **Synthetic data only.** Faker `en_US`. Banner every demo screen.
4. **Confirm before destructive Power Platform operations.** Even in `--yolo` mode.
5. **Document every non-trivial decision** in `.squad/decisions.md` via the inbox pattern (Scribe merges).
6. **Branching:** `feature/p<N>-<name>` (Tier-1 lints regex `^feature/p[0-6]-[a-z0-9-]+$`). After squash-merge, **do NOT delete the branch** — branches are preserved as an educational archive of how each PR was authored. Pre-convention deleted branches are reconstructed under `archive/pr<NN>-<name>`.
7. **Never commit secrets.** `.env.local` only.
8. **Stay in your lane.** Cross-component changes require Lead handoff.
9. **Tests as you go.** Tester is embedded; every role co-authors tests as part of feature work.
10. **Standard envelope.** Every tool flow honors `{success, data, displayMessage, citations[], correlationId, errorCode?}` (Topic 8C).

## When you (an agent) get blocked

1. Check `.squad/decisions.md` first — the answer may already be locked.
2. Check the relevant Topic doc under `docs/_planning/`.
3. Check the Microsoft Learn MCP server for documentation grounding before guessing.
4. Look for a relevant Power Platform skill in the user's environment.
5. If still blocked, **escalate to Lead via the conflict playbook** — do not brute-force, do not silently change scope.
