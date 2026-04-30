/**
 * AppShell — top bar + left nav + content area.
 *
 * Layout per Topic 1 UX lock:
 *  - Top bar: ContinuumLogo (left), PersonaSwitcher (right)
 *  - Left nav: route links; Demo Health nav hidden unless role === DemoOperator
 *  - Content area: children rendered here
 *  - DemoModeBanner: always present at top of content area
 *  - PersonaSwitchAnnouncer: mounted once (sr-only live region)
 *
 * Light mode only (Topic 7 lock).
 * Component #20.
 */
import { type ReactElement, type ReactNode } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { makeStyles, tokens, mergeClasses } from '@fluentui/react-components'
import {
  HomeRegular,
  HeartPulseRegular,
  ShieldCheckmarkRegular,
} from '@fluentui/react-icons'
import { ContinuumLogo } from './ContinuumLogo'
import { DemoModeBanner } from './DemoModeBanner'
import { PersonaSwitcher } from './PersonaSwitcher'
import { PersonaSwitchAnnouncer } from './PersonaSwitchAnnouncer'
import { usePersonaStore } from '../store/personaStore'

const useStyles = makeStyles({
  shell: {
    display: 'flex',
    flexDirection: 'column',
    height: '100vh',
    overflow: 'hidden',
    backgroundColor: tokens.colorNeutralBackground2,
  },
  topBar: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '0 16px',
    height: '52px',
    backgroundColor: tokens.colorNeutralBackground1,
    borderBottom: `1px solid ${tokens.colorNeutralStroke1}`,
    flexShrink: 0,
    zIndex: 100,
  },
  body: {
    display: 'flex',
    flex: 1,
    overflow: 'hidden',
  },
  nav: {
    width: '220px',
    flexShrink: 0,
    backgroundColor: tokens.colorNeutralBackground1,
    borderRight: `1px solid ${tokens.colorNeutralStroke1}`,
    display: 'flex',
    flexDirection: 'column',
    padding: '8px 0',
    overflowY: 'auto',
  },
  navLabel: {
    fontSize: tokens.fontSizeBase100,
    fontWeight: tokens.fontWeightSemibold,
    color: tokens.colorNeutralForeground3,
    textTransform: 'uppercase',
    letterSpacing: '0.06em',
    padding: '12px 16px 4px',
  },
  navLink: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    padding: '8px 16px',
    fontSize: tokens.fontSizeBase300,
    color: tokens.colorNeutralForeground1,
    textDecoration: 'none',
    borderRadius: 0,
    '&:hover': {
      backgroundColor: tokens.colorNeutralBackground1Hover,
      color: tokens.colorNeutralForeground1Hover,
    },
  },
  navLinkActive: {
    backgroundColor: tokens.colorBrandBackground2,
    color: tokens.colorBrandForeground1,
    fontWeight: tokens.fontWeightSemibold,
    '&:hover': {
      backgroundColor: tokens.colorBrandBackground2Hover,
    },
  },
  main: {
    flex: 1,
    overflowY: 'auto',
    display: 'flex',
    flexDirection: 'column',
  },
  content: {
    flex: 1,
    padding: '24px',
  },
})

interface NavLinkItem {
  to: string
  label: string
  icon: ReactElement
}

const PRIMARY_NAV: NavLinkItem[] = [
  { to: '/', label: 'Home', icon: <HomeRegular aria-hidden="true" /> },
  { to: '/account-360', label: 'Account 360', icon: <HeartPulseRegular aria-hidden="true" /> },
]

const OPERATOR_NAV: NavLinkItem[] = [
  { to: '/demo-health', label: 'Demo Health', icon: <ShieldCheckmarkRegular aria-hidden="true" /> },
]

interface AppShellProps {
  children: ReactNode
}

/**
 * AppShell — wrap every route with this component.
 * Light mode only (Topic 7). DemoModeBanner always present.
 * Demo Health nav restricted to DemoOperator role (Topic 3).
 */
export function AppShell({ children }: AppShellProps): ReactElement {
  const styles = useStyles()
  const location = useLocation()
  const { activePersona } = usePersonaStore()
  const isDemoOperator = activePersona.role === 'DemoOperator'

  return (
    <div className={styles.shell}>
      {/* Skip-nav for keyboard / AT users */}
      <a href="#main-content" style={{ position: 'absolute', left: '-9999px', top: 'auto' }}>
        Skip to main content
      </a>

      {/* Top bar */}
      <header className={styles.topBar} role="banner">
        <ContinuumLogo />
        <PersonaSwitcher />
      </header>

      {/* Body: nav + content */}
      <div className={styles.body}>
        {/* Left nav */}
        <nav className={styles.nav} aria-label="Main navigation">
          <span className={styles.navLabel}>Navigation</span>
          {PRIMARY_NAV.map(({ to, label, icon }) => (
            <Link
              key={to}
              to={to}
              className={mergeClasses(
                styles.navLink,
                location.pathname === to ? styles.navLinkActive : '',
              )}
              aria-current={location.pathname === to ? 'page' : undefined}
            >
              {icon}
              {label}
            </Link>
          ))}

          {/* Demo Health — DemoOperator only (Topic 3 lock) */}
          {isDemoOperator && (
            <>
              <span className={styles.navLabel}>Operator</span>
              {OPERATOR_NAV.map(({ to, label, icon }) => (
                <Link
                  key={to}
                  to={to}
                  className={mergeClasses(
                    styles.navLink,
                    location.pathname === to ? styles.navLinkActive : '',
                  )}
                  aria-current={location.pathname === to ? 'page' : undefined}
                >
                  {icon}
                  {label}
                </Link>
              ))}
            </>
          )}
        </nav>

        {/* Main content */}
        <main className={styles.main} id="main-content" tabIndex={-1}>
          <DemoModeBanner />
          <div className={styles.content}>{children}</div>
        </main>
      </div>

      {/* Accessibility: persona switch announcer (sr-only live region) */}
      <PersonaSwitchAnnouncer />
    </div>
  )
}

export default AppShell
