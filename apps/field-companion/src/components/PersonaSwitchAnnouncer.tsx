/**
 * PersonaSwitchAnnouncer — aria-live="polite" region that announces persona
 * changes for screen readers (Topic 7 a11y lock). Component #21.
 *
 * Subscribe to the global `PersonaSwitch` CustomEvent dispatched by the
 * persona store and surface the announcement text in a visually-hidden but
 * screen-reader-visible live region.
 */
import { type ReactElement, useEffect, useState } from 'react'
import { makeStyles } from '@fluentui/react-components'

const useStyles = makeStyles({
  srOnly: {
    position: 'absolute',
    width: '1px',
    height: '1px',
    padding: '0',
    margin: '-1px',
    overflow: 'hidden',
    clip: 'rect(0,0,0,0)',
    whiteSpace: 'nowrap',
    borderTopWidth: '0',
    borderRightWidth: '0',
    borderBottomWidth: '0',
    borderLeftWidth: '0',
  },
})

interface PersonaSwitchDetail {
  toPersonaRole: string
  fromPersonaId: string
  toPersonaId: string
}

/**
 * PersonaSwitchAnnouncer
 *
 * Mount once inside AppShell. Requires no props — listens for the global
 * `PersonaSwitch` window event emitted by `usePersonaStore`.
 */
export function PersonaSwitchAnnouncer(): ReactElement {
  const styles = useStyles()
  const [message, setMessage] = useState('')

  useEffect(() => {
    function handleSwitch(e: Event) {
      const detail = (e as CustomEvent<PersonaSwitchDetail>).detail
      setMessage(`Persona switched to ${detail.toPersonaRole}`)
      // Clear after announcement to allow repeat announcements.
      const timer = setTimeout(() => setMessage(''), 3000)
      return () => clearTimeout(timer)
    }

    window.addEventListener('PersonaSwitch', handleSwitch)
    return () => window.removeEventListener('PersonaSwitch', handleSwitch)
  }, [])

  return (
    <div
      aria-live="polite"
      aria-atomic="true"
      className={styles.srOnly}
      data-testid="persona-switch-announcer"
    >
      {message}
    </div>
  )
}

export default PersonaSwitchAnnouncer
