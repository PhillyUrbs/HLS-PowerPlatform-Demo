# HLS Power Platform Demo

A modular Power Platform demo for **Health & Life Sciences (Medtech)**, built around a
fictitious continuous glucose monitor (CGM) manufacturer — **Contoso Continuum Health**.

The demo showcases all four Power Platform pillars working together:

- **Power Pages** (Code Site, React SPA) — patient & HCP portal
- **Power Apps** (Code App, React + Vite) — Field Clinical Specialist companion
- **Power Automate** — order/replacement orchestration with a mocked carrier API
- **Copilot Studio** — customer-facing, employee-facing, embedded, and agentic agents

It is built primarily by a human + GitHub Copilot + [Squad](https://github.com/bradygaster/squad)
(human-led AI agent teams), with content authored to maximize what Copilot can configure
and deploy directly.

## Status

🚧 **Early scaffolding.** Content is being added phase-by-phase — see the plan in
`docs/` once it lands. Anything in this repo today should be considered a
work-in-progress.

## Scenario at a glance

Five modular 5–10 minute vignettes across four personas:

1. Patient onboarding & in-context support — *Power Pages + Copilot Studio*
2. HCP prescribing & patient roster — *Power Pages (auth) + Power Automate*
3. Field Clinical Specialist account 360 — *Power Apps Code App + embedded agent*
4. Autonomous complaint triage & MDR drafting — *Copilot Studio (triggered)*
5. Employee enablement agent in Teams — *Copilot Studio (knowledge + tools)*

All data is **synthetic**. No real patient information is used or should ever be added.

## Disclaimer & support

This project is provided **AS IS**, without warranty or support of any kind, under the
[MIT License](./LICENSE). The author is a Microsoft Solution Engineer, but this is a
**personal demo asset** — it is not an official Microsoft product, sample, or reference
architecture, and it is not endorsed or supported by Microsoft. Use at your own risk.

Issues and pull requests are welcome but **no response, triage, or fix is promised**.

## License

[MIT](./LICENSE) — © 2026 Philip Urban
