/**
 * Persona overlay store — localStorage-backed via Zustand persist middleware.
 *
 * Holds the active persona for the demo operator persona switcher.
 * Emits `PersonaSwitch` telemetry events on every switch (no-op until
 * `cch_LogTelemetry` flow lands in PR #8).
 *
 * Persona fields per Topic 8C lock:
 *   id, name, role, avatarInitials, primaryAccountId, primaryPatientId,
 *   title, themeAccent
 *
 * Storage key: `cch_activePersona`
 */

import { create } from 'zustand'
import { persist } from 'zustand/middleware'

// ─── Types ───────────────────────────────────────────────────────────────────

export type PersonaRole =
  | 'FieldClinicalSpecialist'
  | 'Endocrinologist'
  | 'Patient'
  | 'QualityAnalyst'
  | 'DemoOperator'
  | 'AnonymousVisitor'

export interface Persona {
  /** Unique stable identifier — used as React key + telemetry subject. */
  id: string
  name: string
  role: PersonaRole
  /** Two-letter initials for the avatar badge. */
  avatarInitials: string
  /** Dataverse accountid for the FCS account-360 panel (optional). */
  primaryAccountId?: string
  /** Dataverse contactid for the patient roster (optional). */
  primaryPatientId?: string
  /** Display title shown in the persona switcher. */
  title: string
  /** Accent hex used as secondary highlight when this persona is active. */
  themeAccent: string
}

export interface PersonaStore {
  activePersona: Persona
  setActivePersona: (persona: Persona) => void
}

// ─── Telemetry helper (no-op until cch_LogTelemetry flow lands) ──────────────

function emitPersonaSwitchEvent(from: Persona, to: Persona): void {
  try {
    window.dispatchEvent(
      new CustomEvent('PersonaSwitch', {
        detail: {
          eventType: 'PersonaSwitch',
          fromPersonaId: from.id,
          fromPersonaRole: from.role,
          toPersonaId: to.id,
          toPersonaRole: to.role,
          timestamp: new Date().toISOString(),
        },
        bubbles: false,
      }),
    )
  } catch {
    // Non-critical — never let telemetry crash the UI.
  }
}

// ─── Default persona — Anonymous Visitor (safe baseline) ─────────────────────

export const ANONYMOUS_VISITOR_PERSONA: Persona = {
  id: 'anonymous-visitor',
  name: 'Anonymous Visitor',
  role: 'AnonymousVisitor',
  avatarInitials: 'AV',
  title: 'Browse mode',
  themeAccent: '#6B6B6B',
}

// ─── Full demo persona roster (synthetic data only — Faker-sourced) ───────────

export const DEMO_PERSONAS: Persona[] = [
  ANONYMOUS_VISITOR_PERSONA,
  {
    id: 'fcs-alex-rivera',
    name: 'Alex Rivera',
    role: 'FieldClinicalSpecialist',
    avatarInitials: 'AR',
    primaryAccountId: 'acc-contoso-northwest-001',
    title: 'Field Clinical Specialist',
    themeAccent: '#0E7C86',
  },
  {
    id: 'hcp-dr-priya-nair',
    name: 'Dr. Priya Nair',
    role: 'Endocrinologist',
    avatarInitials: 'PN',
    primaryPatientId: 'pat-synthetic-00142',
    title: 'Endocrinologist',
    themeAccent: '#5C2D91',
  },
  {
    id: 'patient-jordan-walsh',
    name: 'Jordan Walsh',
    role: 'Patient',
    avatarInitials: 'JW',
    primaryPatientId: 'pat-synthetic-00142',
    title: 'Patient',
    themeAccent: '#004578',
  },
  {
    id: 'qa-morgan-lee',
    name: 'Morgan Lee',
    role: 'QualityAnalyst',
    avatarInitials: 'ML',
    title: 'Quality / Complaints Analyst',
    themeAccent: '#B83C00',
  },
  {
    id: 'demo-operator',
    name: 'Demo Operator',
    role: 'DemoOperator',
    avatarInitials: 'DO',
    title: 'Demo Operator',
    themeAccent: '#107C10',
  },
]

// ─── Store ────────────────────────────────────────────────────────────────────

export const usePersonaStore = create<PersonaStore>()(
  persist(
    (set, get) => ({
      activePersona: ANONYMOUS_VISITOR_PERSONA,
      setActivePersona: (persona: Persona) => {
        const from = get().activePersona
        if (from.id === persona.id) return
        emitPersonaSwitchEvent(from, persona)
        set({ activePersona: persona })
      },
    }),
    {
      name: 'cch_activePersona',
      // Persist the full persona object.
      partialize: (state) => ({ activePersona: state.activePersona }),
    },
  ),
)
