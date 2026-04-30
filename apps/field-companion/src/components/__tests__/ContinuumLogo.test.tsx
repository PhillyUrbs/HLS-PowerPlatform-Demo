import { render } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'
import { FluentProvider, webLightTheme } from '@fluentui/react-components'
import { ContinuumLogo } from '../ContinuumLogo'
import { describe, it, expect } from 'vitest'
import type { ReactNode } from 'react'

expect.extend(toHaveNoViolations)

function Wrapper({ children }: { children: ReactNode }) {
  return <FluentProvider theme={webLightTheme}>{children}</FluentProvider>
}

describe('ContinuumLogo', () => {
  it('has no axe accessibility violations', async () => {
    const { container } = render(<ContinuumLogo />, { wrapper: Wrapper })
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })

  it('renders with custom brand color', async () => {
    const { container } = render(<ContinuumLogo brandColor="#FF0000" />, { wrapper: Wrapper })
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })

  it('accepts a custom label', () => {
    const { getByRole, getByTitle } = render(<ContinuumLogo label="My Company" />, { wrapper: Wrapper })
    expect(getByRole('img', { hidden: true })).toBeInTheDocument()
    expect(getByTitle('My Company')).toBeInTheDocument()
  })
})
