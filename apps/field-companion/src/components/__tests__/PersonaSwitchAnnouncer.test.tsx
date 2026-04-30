import { render, screen, fireEvent, act } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'
import { FluentProvider, webLightTheme } from '@fluentui/react-components'
import { PersonaSwitchAnnouncer } from '../PersonaSwitchAnnouncer'
import { describe, it, expect, afterEach } from 'vitest'
import type { ReactNode } from 'react'

expect.extend(toHaveNoViolations)

function Wrapper({ children }: { children: ReactNode }) {
  return <FluentProvider theme={webLightTheme}>{children}</FluentProvider>
}

describe('PersonaSwitchAnnouncer', () => {
  afterEach(() => {
    // Clean up any lingering timers
  })

  it('has no axe accessibility violations when idle', async () => {
    const { container } = render(<PersonaSwitchAnnouncer />, { wrapper: Wrapper })
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })

  it('renders a polite aria-live region', () => {
    render(<PersonaSwitchAnnouncer />, { wrapper: Wrapper })
    const region = screen.getByTestId('persona-switch-announcer')
    expect(region).toHaveAttribute('aria-live', 'polite')
    expect(region).toHaveAttribute('aria-atomic', 'true')
  })

  it('announces persona switch on CustomEvent', async () => {
    render(<PersonaSwitchAnnouncer />, { wrapper: Wrapper })
    const region = screen.getByTestId('persona-switch-announcer')

    await act(async () => {
      window.dispatchEvent(
        new CustomEvent('PersonaSwitch', {
          detail: {
            fromPersonaId: 'anonymous-visitor',
            fromPersonaRole: 'AnonymousVisitor',
            toPersonaId: 'fcs-alex-rivera',
            toPersonaRole: 'FieldClinicalSpecialist',
            timestamp: new Date().toISOString(),
          },
        }),
      )
    })

    expect(region.textContent).toMatch(/FieldClinicalSpecialist/)
  })

  it('has no axe violations after a persona switch announcement', async () => {
    const { container } = render(<PersonaSwitchAnnouncer />, { wrapper: Wrapper })

    await act(async () => {
      window.dispatchEvent(
        new CustomEvent('PersonaSwitch', {
          detail: {
            fromPersonaId: 'anonymous-visitor',
            fromPersonaRole: 'AnonymousVisitor',
            toPersonaId: 'demo-operator',
            toPersonaRole: 'DemoOperator',
            timestamp: new Date().toISOString(),
          },
        }),
      )
    })

    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })
})
