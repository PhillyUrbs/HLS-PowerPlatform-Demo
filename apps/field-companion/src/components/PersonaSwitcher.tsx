/**
 * PersonaSwitcher — always-visible top-right dropdown component.
 * Renders a searchable persona selection panel using Fluent UI v9 primitives.
 * Includes the Anonymous Visitor pseudo-persona.
 *
 * Always visible regardless of active persona (Topic 1 UX lock).
 * Component #22.
 */
import { type ReactElement, useState, useId } from 'react'
import {
  Avatar,
  Button,
  Input,
  makeStyles,
  Menu,
  MenuList,
  MenuPopover,
  MenuTrigger,
  tokens,
} from '@fluentui/react-components'
import { PersonRegular, SearchRegular } from '@fluentui/react-icons'
import {
  usePersonaStore,
  DEMO_PERSONAS,
  type Persona,
} from '../store/personaStore'

const useStyles = makeStyles({
  triggerButton: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    padding: '4px 8px',
    borderRadius: tokens.borderRadiusMedium,
    cursor: 'pointer',
    border: `1px solid ${tokens.colorNeutralStroke1}`,
    backgroundColor: tokens.colorNeutralBackground1,
    color: tokens.colorNeutralForeground1,
    fontSize: tokens.fontSizeBase200,
    fontWeight: tokens.fontWeightSemibold,
    '&:hover': {
      backgroundColor: tokens.colorNeutralBackground1Hover,
    },
  },
  menuContent: {
    padding: '8px',
    minWidth: '260px',
    maxWidth: '320px',
  },
  searchWrapper: {
    marginBottom: '8px',
  },
  personaItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    padding: '8px 10px',
    borderRadius: tokens.borderRadiusMedium,
    cursor: 'pointer',
    width: '100%',
    backgroundColor: 'transparent',
    border: 'none',
    textAlign: 'left',
    color: tokens.colorNeutralForeground1,
    fontSize: tokens.fontSizeBase200,
    '&:hover': {
      backgroundColor: tokens.colorNeutralBackground1Hover,
    },
  },
  personaItemActive: {
    backgroundColor: tokens.colorBrandBackground2,
    '&:hover': {
      backgroundColor: tokens.colorBrandBackground2Hover,
    },
  },
  personaName: {
    fontWeight: tokens.fontWeightSemibold,
    display: 'block',
  },
  personaTitle: {
    display: 'block',
    fontSize: tokens.fontSizeBase100,
    color: tokens.colorNeutralForeground3,
  },
  listScrollable: {
    maxHeight: '320px',
    overflowY: 'auto',
  },
})

function PersonaItem({
  persona,
  isActive,
  onSelect,
}: {
  persona: Persona
  isActive: boolean
  onSelect: (p: Persona) => void
}): ReactElement {
  const styles = useStyles()

  return (
    <button
      type="button"
      className={`${styles.personaItem} ${isActive ? styles.personaItemActive : ''}`}
      onClick={() => onSelect(persona)}
      aria-pressed={isActive}
      aria-label={`Switch to ${persona.name} — ${persona.title}`}
    >
      <Avatar
        name={persona.name}
        initials={persona.avatarInitials}
        size={28}
        color="colorful"
        aria-hidden="true"
      />
      <span>
        <span className={styles.personaName}>{persona.name}</span>
        <span className={styles.personaTitle}>{persona.title}</span>
      </span>
    </button>
  )
}

/**
 * PersonaSwitcher
 *
 * Mount once in AppShell top bar (always visible; top-right per Topic 1 lock).
 */
export function PersonaSwitcher(): ReactElement {
  const styles = useStyles()
  const { activePersona, setActivePersona } = usePersonaStore()
  const [search, setSearch] = useState('')
  const searchId = useId()

  const filtered = DEMO_PERSONAS.filter(
    (p) =>
      p.name.toLowerCase().includes(search.toLowerCase()) ||
      p.title.toLowerCase().includes(search.toLowerCase()),
  )

  return (
    <Menu>
      <MenuTrigger disableButtonEnhancement>
        <Button
          className={styles.triggerButton}
          icon={
            <Avatar
              name={activePersona.name}
              initials={activePersona.avatarInitials}
              size={20}
              color="colorful"
              aria-hidden="true"
            />
          }
          iconPosition="before"
          appearance="subtle"
          aria-label={`Active persona: ${activePersona.name}. Click to switch persona.`}
        >
          {activePersona.name}
        </Button>
      </MenuTrigger>

      <MenuPopover>
        <div className={styles.menuContent}>
          <div className={styles.searchWrapper}>
            <Input
              id={searchId}
              contentBefore={<PersonRegular aria-hidden="true" />}
              placeholder="Search personas…"
              value={search}
              onChange={(_, d) => setSearch(d.value)}
              aria-label="Search personas"
              contentAfter={<SearchRegular aria-hidden="true" />}
            />
          </div>
          <MenuList>
            <div className={styles.listScrollable}>
              {filtered.length === 0 && (
                <p style={{ padding: '8px', color: tokens.colorNeutralForeground3, fontSize: tokens.fontSizeBase200 }}>
                  No personas match &ldquo;{search}&rdquo;
                </p>
              )}
              {filtered.map((p) => (
                <PersonaItem
                  key={p.id}
                  persona={p}
                  isActive={p.id === activePersona.id}
                  onSelect={(selected) => {
                    setActivePersona(selected)
                    setSearch('')
                  }}
                />
              ))}
            </div>
          </MenuList>
        </div>
      </MenuPopover>
    </Menu>
  )
}

export default PersonaSwitcher
