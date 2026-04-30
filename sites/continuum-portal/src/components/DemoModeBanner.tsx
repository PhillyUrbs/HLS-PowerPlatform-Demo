import { type ReactElement, useCallback, useEffect, useState } from 'react'
import {
  MessageBar,
  MessageBarBody,
  MessageBarActions,
  Button,
  makeStyles,
} from '@fluentui/react-components'
import { DismissRegular } from '@fluentui/react-icons'

const SESSION_KEY = 'cch_demoBannerDismissed'

const useStyles = makeStyles({
  root: {
    width: '100%',
  },
})

/**
 * DemoModeBanner — mounts at the site shell; present on every page.
 * Dismissible per session (sessionStorage); returns on every page refresh,
 * new tab, or persona switch (Topic 2 lock).
 * Component #19 in the shared component library (Topic 11 §C1 running count).
 *
 * DATA NOTICE: All data displayed in this demo is entirely synthetic
 * and generated using Faker.js. No real PHI is used.
 */
export function DemoModeBanner(): ReactElement | null {
  const styles = useStyles()

  const [visible, setVisible] = useState<boolean>(() => {
    try {
      return sessionStorage.getItem(SESSION_KEY) !== 'true'
    } catch {
      return true
    }
  })

  useEffect(() => {
    try {
      if (!visible) {
        sessionStorage.setItem(SESSION_KEY, 'true')
      }
    } catch {
      // sessionStorage not available — always show
    }
  }, [visible])

  const handleDismiss = useCallback(() => {
    setVisible(false)
  }, [])

  if (!visible) return null

  return (
    <div className={styles.root} role="region" aria-label="Demo mode notice">
      <MessageBar intent="warning" layout="multiline">
        <MessageBarBody>
          <strong>⚕ Demo mode — Contoso Continuum Health.</strong>{' '}
          All patient names, MRNs, device IDs, and clinical data are entirely synthetic
          (generated with Faker.js). This is not a Microsoft product or official reference.
          Provided AS-IS under the MIT License. Not validated for FDA/HIPAA/GxP use.
        </MessageBarBody>
        <MessageBarActions
          containerAction={
            <Button
              appearance="transparent"
              icon={<DismissRegular />}
              onClick={handleDismiss}
              aria-label="Dismiss demo mode notice"
            />
          }
        />
      </MessageBar>
    </div>
  )
}

export default DemoModeBanner
