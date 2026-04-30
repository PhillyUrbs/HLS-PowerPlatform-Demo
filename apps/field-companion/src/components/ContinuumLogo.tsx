import { type ReactElement, type CSSProperties } from 'react'
import { makeStyles, tokens } from '@fluentui/react-components'

const useStyles = makeStyles({
  root: {
    display: 'inline-flex',
    alignItems: 'center',
    gap: '8px',
    textDecoration: 'none',
  },
  wordmark: {
    fontSize: '18px',
    fontWeight: '600',
    color: 'var(--cch-brand-teal, #0E7C86)',
    lineHeight: 1,
    fontFamily: tokens.fontFamilyBase,
  },
})

export interface ContinuumLogoProps {
  /** Override the brand teal color via CSS custom property. Defaults to #0E7C86. */
  brandColor?: string
  /** Height of the SVG mark in pixels. Defaults to 32. */
  size?: number
  /** Accessible label for screen readers. Defaults to "Continuum Health". */
  label?: string
}

/**
 * ContinuumLogo — hand-authored SVG mark + wordmark.
 * Accepts a CSS variable override for the brand teal token (#0E7C86, Topic 2 lock).
 * Copied from sites/continuum-portal/src/components/ContinuumLogo.tsx (Phase 3 scaffold).
 * Component #18 in the shared component library (Topic 11 §C1 running count).
 */
export function ContinuumLogo({
  brandColor = '#0E7C86',
  size = 32,
  label = 'Continuum Health',
}: ContinuumLogoProps): ReactElement {
  const styles = useStyles()

  return (
    <span className={styles.root} style={{ '--cch-brand-teal': brandColor } as CSSProperties}>
      {/* CGM-inspired circular arc mark */}
      <svg
        width={size}
        height={size}
        viewBox="0 0 32 32"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        aria-hidden="true"
        focusable="false"
        role="img"
      >
        <title>{label}</title>
        {/* Outer arc — represents the CGM sensor ring */}
        <path
          d="M16 4 A12 12 0 1 1 4 16"
          stroke="var(--cch-brand-teal, #0E7C86)"
          strokeWidth="3"
          strokeLinecap="round"
          fill="none"
        />
        {/* Inner glucose curve — stylised waveform */}
        <path
          d="M8 20 Q12 12 16 16 Q20 20 24 14"
          stroke="var(--cch-brand-teal, #0E7C86)"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
        {/* Centre dot — sensor reading indicator */}
        <circle cx="16" cy="16" r="2" fill="var(--cch-brand-teal, #0E7C86)" />
      </svg>
      <span className={styles.wordmark} aria-hidden="true">
        Continuum Health
      </span>
    </span>
  )
}

export default ContinuumLogo
