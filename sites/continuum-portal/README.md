# continuum-portal

**Power Pages Code Site** for the Contoso Continuum Health medtech CGM demo.

React 18 + Vite 6 + TypeScript 5.6 + Fluent UI v9 single-page application, deployed as a
Power Pages Code Site. Covers Vignettes 1 (patient onboarding) and 2 (HCP prescribing).

> ⚕ **All data is entirely synthetic** — generated with Faker.js. Not a Microsoft product.
> Provided AS-IS under the MIT License. Not validated for FDA/HIPAA/GxP use.

## Development

```bash
npm install
npm run dev        # local Vite dev server
npm run build      # tsc --noEmit + vite build
npm run test       # vitest unit suite
npm run test:a11y  # axe accessibility suite
```

Requires Node ≥ 20.

## Structure

```
src/
  App.tsx                    # FluentProvider shell + DemoModeBanner
  theme.ts                   # Brand tokens (teal #0E7C86)
  components/
    ContinuumLogo.tsx        # SVG mark + wordmark (#18)
    DemoModeBanner.tsx       # Synthetic-data warning banner (#19)
    __tests__/               # jest-axe a11y tests
```

## Deployment

Use the `deploy-site` + `activate-site` Power Platform skills. See
[`AGENTS.md`](./AGENTS.md) for web-role and permission requirements.
