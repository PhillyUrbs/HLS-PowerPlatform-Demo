/**
 * DemoHealth — operator-only route at /demo-health.
 *
 * Phase-3 scaffold: placeholder tiles only.
 * Real `doctor.ps1 --vignette=V_` JSON wiring is deferred to a follow-up issue.
 *
 * Nav access restricted to DemoOperator persona role (Topic 3 lock).
 * A non-operator who navigates here directly sees an access-denied message.
 */
import { type ReactElement } from 'react'
import {
  Card,
  CardHeader,
  makeStyles,
  Text,
  tokens,
  Badge,
} from '@fluentui/react-components'
import { ShieldCheckmarkRegular, LockClosedRegular } from '@fluentui/react-icons'
import { usePersonaStore } from '../store/personaStore'

const useStyles = makeStyles({
  page: {
    maxWidth: '900px',
  },
  heading: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    marginBottom: '8px',
  },
  subtext: {
    color: tokens.colorNeutralForeground3,
    fontSize: tokens.fontSizeBase200,
    marginBottom: '24px',
    display: 'block',
  },
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
    gap: '16px',
  },
  card: {
    cursor: 'default',
  },
  tileStatus: {
    marginTop: '8px',
  },
  denied: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '16px',
    padding: '48px 24px',
    textAlign: 'center',
  },
})

interface VignetteTile {
  id: string
  label: string
  description: string
  status: 'pending' | 'ready'
}

const VIGNETTE_TILES: VignetteTile[] = [
  {
    id: 'v1',
    label: 'V1 — Patient Onboarding',
    description: 'Patient onboarding & in-context support (Pages + agent + flow).',
    status: 'pending',
  },
  {
    id: 'v2',
    label: 'V2 — HCP Prescribing',
    description: 'HCP prescribing & patient roster (Pages auth + Web API + flow).',
    status: 'pending',
  },
  {
    id: 'v3',
    label: 'V3 — FCS Account 360',
    description: 'Field Clinical Specialist account 360 (Code App + embedded agent).',
    status: 'pending',
  },
  {
    id: 'v4',
    label: 'V4 — Complaint Triage',
    description: 'Autonomous complaint triage & MDR drafting (Copilot Studio).',
    status: 'pending',
  },
  {
    id: 'v5',
    label: 'V5 — Employee Enablement',
    description: 'Employee enablement agent (Copilot Studio, knowledge + tools).',
    status: 'pending',
  },
  {
    id: 'v6',
    label: 'V6 — Extend Everywhere',
    description: 'Same agent surfaced in Code App, Teams, SharePoint, and M365 Copilot.',
    status: 'pending',
  },
]

/**
 * DemoHealth page — operator view.
 *
 * Phase 3 scaffold: tiles are placeholders.
 * `doctor.ps1 --vignette=V_` JSON wiring lands in a follow-up PR.
 */
export function DemoHealth(): ReactElement {
  const styles = useStyles()
  const { activePersona } = usePersonaStore()

  // Guard: non-operator sees access denied
  if (activePersona.role !== 'DemoOperator') {
    return (
      <div className={styles.denied} role="alert">
        <LockClosedRegular fontSize={48} color={tokens.colorNeutralForeground3} aria-hidden="true" />
        <Text size={500} weight="semibold">
          Demo Health — Operator Access Only
        </Text>
        <Text size={300} style={{ color: tokens.colorNeutralForeground3 }}>
          Switch to the <strong>Demo Operator</strong> persona using the persona switcher
          in the top-right corner to access this page.
        </Text>
      </div>
    )
  }

  return (
    <section className={styles.page} aria-labelledby="demo-health-heading">
      <div className={styles.heading}>
        <ShieldCheckmarkRegular fontSize={24} color="#107C10" aria-hidden="true" />
        <Text id="demo-health-heading" as="h1" size={600} weight="semibold">
          Demo Health
        </Text>
      </div>
      <Text as="span" className={styles.subtext}>
        Vignette pre-flight status. Placeholder tiles — real <code>doctor.ps1 --vignette</code> wiring
        is deferred to a follow-up Phase 3 PR.
      </Text>

      <div className={styles.grid}>
        {VIGNETTE_TILES.map((tile) => (
          <Card key={tile.id} className={styles.card} aria-label={tile.label}>
            <CardHeader
              header={
                <Text weight="semibold" size={300}>
                  {tile.label}
                </Text>
              }
              description={
                <Text size={200} style={{ color: tokens.colorNeutralForeground3 }}>
                  {tile.description}
                </Text>
              }
            />
            <div className={styles.tileStatus}>
              <Badge
                appearance="tint"
                color={tile.status === 'ready' ? 'success' : 'warning'}
                shape="rounded"
              >
                {tile.status === 'ready' ? 'Ready' : 'Pending'}
              </Badge>
            </div>
          </Card>
        ))}
      </div>
    </section>
  )
}

export default DemoHealth
