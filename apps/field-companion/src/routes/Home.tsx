/**
 * Home — default landing page for the Field Companion Code App.
 * Phase 3 scaffold: placeholder content.
 * V3 (Account 360) and V4 (Quality workspace) land in follow-up PRs.
 */
import { type ReactElement } from 'react'
import { Text, makeStyles, tokens } from '@fluentui/react-components'
import { usePersonaStore } from '../store/personaStore'

const useStyles = makeStyles({
  page: {
    maxWidth: '720px',
  },
  greeting: {
    marginBottom: '8px',
    display: 'block',
  },
  subtext: {
    color: tokens.colorNeutralForeground3,
    display: 'block',
  },
})

export function Home(): ReactElement {
  const styles = useStyles()
  const { activePersona } = usePersonaStore()

  return (
    <section className={styles.page} aria-labelledby="home-heading">
      <Text id="home-heading" as="h1" size={600} weight="semibold" className={styles.greeting}>
        Welcome, {activePersona.name}
      </Text>
      <Text as="p" size={300} className={styles.subtext}>
        Continuum Health Field Companion — Phase 3 scaffold. V3 Account 360, V4 Quality workspace,
        and V5 Knowledge tab will be added in subsequent CodeApp-Engineer PRs.
      </Text>
    </section>
  )
}

export default Home
