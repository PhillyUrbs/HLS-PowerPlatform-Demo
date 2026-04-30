import { describe, it, expect, beforeEach, vi } from 'vitest'
import { usePersonaStore, DEMO_PERSONAS, ANONYMOUS_VISITOR_PERSONA, type Persona } from '../personaStore'

describe('personaStore', () => {
  beforeEach(() => {
    // Reset store to default state
    usePersonaStore.setState({ activePersona: ANONYMOUS_VISITOR_PERSONA })
    // Clear localStorage
    try {
      localStorage.removeItem('cch_activePersona')
    } catch {
      // ignore
    }
  })

  it('starts with the Anonymous Visitor persona', () => {
    const { activePersona } = usePersonaStore.getState()
    expect(activePersona.id).toBe('anonymous-visitor')
    expect(activePersona.role).toBe('AnonymousVisitor')
  })

  it('switches to a new persona', () => {
    const fcs = DEMO_PERSONAS.find((p) => p.role === 'FieldClinicalSpecialist')!
    usePersonaStore.getState().setActivePersona(fcs)
    expect(usePersonaStore.getState().activePersona.id).toBe(fcs.id)
  })

  it('is a no-op when switching to the same persona', () => {
    const initial = usePersonaStore.getState().activePersona
    usePersonaStore.getState().setActivePersona(initial)
    expect(usePersonaStore.getState().activePersona).toBe(initial)
  })

  it('emits a PersonaSwitch CustomEvent on switch', () => {
    const listener = vi.fn()
    window.addEventListener('PersonaSwitch', listener)

    const fcs = DEMO_PERSONAS.find((p) => p.role === 'FieldClinicalSpecialist')!
    usePersonaStore.getState().setActivePersona(fcs)

    expect(listener).toHaveBeenCalledTimes(1)
    const event = listener.mock.calls[0][0] as CustomEvent
    expect(event.detail.toPersonaId).toBe(fcs.id)
    expect(event.detail.fromPersonaId).toBe('anonymous-visitor')

    window.removeEventListener('PersonaSwitch', listener)
  })

  it('does not emit PersonaSwitch when persona id is unchanged', () => {
    const listener = vi.fn()
    window.addEventListener('PersonaSwitch', listener)

    const current = usePersonaStore.getState().activePersona
    usePersonaStore.getState().setActivePersona(current)

    expect(listener).not.toHaveBeenCalled()

    window.removeEventListener('PersonaSwitch', listener)
  })

  it('DEMO_PERSONAS includes Anonymous Visitor', () => {
    expect(DEMO_PERSONAS.some((p) => p.role === 'AnonymousVisitor')).toBe(true)
  })

  it('DEMO_PERSONAS includes all required roles', () => {
    const roles = DEMO_PERSONAS.map((p) => p.role)
    const required: Persona['role'][] = [
      'AnonymousVisitor',
      'FieldClinicalSpecialist',
      'Endocrinologist',
      'Patient',
      'QualityAnalyst',
      'DemoOperator',
    ]
    for (const role of required) {
      expect(roles).toContain(role)
    }
  })

  it('all personas have required fields', () => {
    for (const p of DEMO_PERSONAS) {
      expect(p.id).toBeTruthy()
      expect(p.name).toBeTruthy()
      expect(p.role).toBeTruthy()
      expect(p.avatarInitials).toBeTruthy()
      expect(p.title).toBeTruthy()
      expect(p.themeAccent).toBeTruthy()
    }
  })
})
