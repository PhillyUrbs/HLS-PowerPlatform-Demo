import { FluentProvider, webLightTheme } from '@fluentui/react-components'
import { DemoModeBanner } from './components/DemoModeBanner'
import { ContinuumLogo } from './components/ContinuumLogo'

/**
 * App shell — Continuum Portal (Power Pages Code Site).
 * Light mode only (Topic 7 lock). DemoModeBanner is always present.
 */
function App() {
  return (
    <FluentProvider theme={webLightTheme}>
      <DemoModeBanner />
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          padding: '12px 24px',
          borderBottom: '1px solid #e0e0e0',
        }}
      >
        <ContinuumLogo />
      </header>
      <main style={{ padding: '24px' }}>
        {/* Vignette routes will mount here */}
        <p>Continuum Health Patient Portal — Phase 2 scaffold</p>
      </main>
    </FluentProvider>
  )
}

export default App
