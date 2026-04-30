import { render, screen } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'
import { FluentProvider, webLightTheme } from '@fluentui/react-components'
import { PersonaSwitcher } from '../PersonaSwitcher'
import { usePersonaStore, DEMO_PERSONAS, ANONYMOUS_VISITOR_PERSONA } from '../../store/personaStore'
import { describe, it, expect, beforeEach } from 'vitest'
import type { ReactNode } from 'react'

expect.extend(toHaveNoViolations)

function Wrapper({ children }: { children: ReactNode }) {
  return <FluentProvider theme={webLightTheme}>{children}</FluentProvider>
}

describe('PersonaSwitcher', () => {
  beforeEach(() => {
    usePersonaStore.setState({ activePersona: ANONYMOUS_VISITOR_PERSONA })
  })

  it('has no axe accessibility violations', async () => {
    const { container } = render(<PersonaSwitcher />, { wrapper: Wrapper })
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })

  it('renders the active persona name in the trigger button', () => {
    render(<PersonaSwitcher />, { wrapper: Wrapper })
    expect(screen.getByText(ANONYMOUS_VISITOR_PERSONA.name)).toBeInTheDocument()
  })

  it('renders the trigger button with accessible label', () => {
    render(<PersonaSwitcher />, { wrapper: Wrapper })
    const btn = screen.getByRole('button', { name: /active persona/i })
    expect(btn).toBeInTheDocument()
  })

  it('renders with a different active persona', () => {
    const fcs = DEMO_PERSONAS.find((p) => p.role === 'FieldClinicalSpecialist')!
    usePersonaStore.setState({ activePersona: fcs })
    render(<PersonaSwitcher />, { wrapper: Wrapper })
    expect(screen.getByText(fcs.name)).toBeInTheDocument()
  })
})
