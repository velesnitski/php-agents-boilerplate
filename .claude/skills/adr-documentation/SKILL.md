---
name: adr-documentation
description: Architecture Decision Records – format, conventions, when to write
user-invocable: false
---

# Architecture Decision Records (ADR)

## Location
```
docs/adr/
  001-short-descriptive-title.md
  002-another-decision.md
  ...
```

## When to Write an ADR
- Choosing between two or more viable approaches
- Deviating from standard patterns (e.g. string concat instead of YAML library)
- Removing significant functionality or simplifying architecture
- Introducing new dependencies or external services
- Changing data models or API contracts
- Any decision that future developers might question "why?"

## Format

```markdown
# NNN – Title

## Status
Accepted | Superseded by NNN | Deprecated

## Context
What is the problem? What constraints exist? What alternatives were considered?

## Decision
What was decided and why this option over others.

## Consequences
What are the trade-offs? What becomes easier? What becomes harder?
What follow-up work is needed?
```

## Conventions
- Sequential numbering: `001`, `002`, `003`...
- Title is a short noun phrase describing the decision, not the problem
- Context section must list alternatives that were rejected and why
- Every commit that introduces architectural changes must include the ADR
- ADRs are immutable once accepted – create a new one to supersede
- Keep them short – 1 page is ideal, 2 pages max

## Examples of Good ADR Titles
- `001-uuid-generation-from-password.md`
- `002-table-prefix-mapping.md`
- `003-frontend-integration-approach.md`
- `004-subscription-token-flow.md`
- `005-known-issues.md`

## Anti-Patterns
- Writing ADRs for trivial decisions (variable naming, formatting)
- Omitting rejected alternatives – the "why not" is as valuable as "why"
- Updating old ADRs instead of superseding them
- Skipping ADRs for "obvious" decisions – what's obvious now won't be in 6 months
