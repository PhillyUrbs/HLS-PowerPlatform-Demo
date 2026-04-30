import { render, screen } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'
import { FluentProvider, webLightTheme } from '@fluentui/react-components'
import { MemoryRouter } from 'react-router-dom'
import { AppShell } from '../AppShell'
import { usePersonaStore, DEMO_PERSONAS } from '../../store/personaStore'
import { describe, it, expect, beforeEach } from 'vitest'
import type { ReactNode } from 'react'

expect.extend(toHaveNoViolations)

function Wrapper({ children }: { children: ReactNode }) {
  return (
    <FluentProvider theme={webLightTheme}>
      <MemoryRouter>{children}</MemoryRouter>
    </FluentProvider>
  )
}

describe('AppShell', () => {
  beforeEach(() => {
    sessionStorage.clear()
    // Reset persona to anonymous visitor
    const anonymous = DEMO_PERSONAS.find((p) => p.id === 'anonymous-visitor')!
    usePersonaStore.setState({ activePersona: anonymous })
  })

  it('has no axe accessibility violations (AnonymousVisitor)', async () => {
    const { container } = render(
      <AppShell>
        <p>Content</p>
      </AppShell>,
      { wrapper: Wrapper },
    )
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })

  it('renders the top bar with logo and persona switcher', () => {
    render(
      <AppShell>
        <p>Content</p>
      </AppShell>,
      { wrapper: Wrapper },
    )
    expect(screen.getByRole('banner')).toBeInTheDocument()
    expect(screen.getByRole('navigation', { name: /main navigation/i })).toBeInTheDocument()
  })

  it('renders DemoModeBanner inside content area', () => {
    render(
      <AppShell>
        <p>Content</p>
      </AppShell>,
      { wrapper: Wrapper },
    )
    // Banner should be present (sessionStorage is cleared in beforeEach)
    expect(screen.getByText(/entirely synthetic/i)).toBeInTheDocument()
  })

  it('hides Demo Health nav link for non-DemoOperator', () => {
    render(
      <AppShell>
        <p>Content</p>
      </AppShell>,
      { wrapper: Wrapper },
    )
    expect(screen.queryByText('Demo Health')).not.toBeInTheDocument()
  })

  it('shows Demo Health nav link for DemoOperator persona', () => {
    const operator = DEMO_PERSONAS.find((p) => p.role === 'DemoOperator')!
    usePersonaStore.setState({ activePersona: operator })

    render(
      <AppShell>
        <p>Content</p>
      </AppShell>,
      { wrapper: Wrapper },
    )
    expect(screen.getByText('Demo Health')).toBeInTheDocument()
  })

  it('has no axe violations with DemoOperator persona active', async () => {
    const operator = DEMO_PERSONAS.find((p) => p.role === 'DemoOperator')!
    usePersonaStore.setState({ activePersona: operator })

    const { container } = render(
      <AppShell>
        <p>Content</p>
      </AppShell>,
      { wrapper: Wrapper },
    )
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })
})
