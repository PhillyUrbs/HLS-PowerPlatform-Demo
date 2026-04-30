import { render, screen, fireEvent } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'
import { FluentProvider, webLightTheme } from '@fluentui/react-components'
import { DemoModeBanner } from '../DemoModeBanner'
import { describe, it, expect, beforeEach } from 'vitest'
import type { ReactNode } from 'react'

expect.extend(toHaveNoViolations)

function Wrapper({ children }: { children: ReactNode }) {
  return <FluentProvider theme={webLightTheme}>{children}</FluentProvider>
}

describe('DemoModeBanner', () => {
  beforeEach(() => {
    sessionStorage.clear()
  })

  it('has no axe accessibility violations when visible', async () => {
    const { container } = render(<DemoModeBanner />, { wrapper: Wrapper })
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })

  it('renders the synthetic data notice', () => {
    render(<DemoModeBanner />, { wrapper: Wrapper })
    expect(screen.getByText(/entirely synthetic/i)).toBeInTheDocument()
  })

  it('is dismissed when the dismiss button is clicked', () => {
    render(<DemoModeBanner />, { wrapper: Wrapper })
    const button = screen.getByRole('button', { name: /dismiss demo mode notice/i })
    fireEvent.click(button)
    expect(screen.queryByText(/entirely synthetic/i)).not.toBeInTheDocument()
  })

  it('stores dismissal in sessionStorage', () => {
    render(<DemoModeBanner />, { wrapper: Wrapper })
    const button = screen.getByRole('button', { name: /dismiss demo mode notice/i })
    fireEvent.click(button)
    expect(sessionStorage.getItem('cch_demoBannerDismissed')).toBe('true')
  })

  it('does not render when already dismissed in session', () => {
    sessionStorage.setItem('cch_demoBannerDismissed', 'true')
    render(<DemoModeBanner />, { wrapper: Wrapper })
    expect(screen.queryByText(/entirely synthetic/i)).not.toBeInTheDocument()
  })
})
