import { FluentProvider, webLightTheme } from '@fluentui/react-components'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AppShell } from './components/AppShell'
import { Home } from './routes/Home'
import { DemoHealth } from './routes/DemoHealth'

/**
 * App — Field Companion Power Apps Code App root.
 * Light mode only (Topic 7 lock).
 * Routes:
 *   /             → Home (placeholder, Phase 3 scaffold)
 *   /demo-health  → DemoHealth (operator only, Topic 3)
 *   *             → redirect to /
 */
function App() {
  return (
    <FluentProvider theme={webLightTheme}>
      <BrowserRouter>
        <AppShell>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/demo-health" element={<DemoHealth />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </AppShell>
      </BrowserRouter>
    </FluentProvider>
  )
}

export default App
