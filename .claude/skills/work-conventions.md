---
name: work-conventions
description: Shared team conventions for code, commits, and communication
---

# Work Conventions

## Git
- Branch naming: `feature/TICKET-123-short-desc`, `fix/TICKET-456-short-desc`, `hotfix/...`
- Commit messages: imperative mood, reference ticket ID
- One logical change per commit – don't mix refactoring with features
- Never force-push to shared branches

## Code Review Checklist
- [ ] Tests pass
- [ ] No new warnings or deprecations
- [ ] No hardcoded credentials or IPs
- [ ] No `env()` outside config files
- [ ] Migrations have `down()` method
- [ ] API changes documented

## Communication
- Agent output must be structured (use the defined output format)
- Flag blockers immediately – don't silently skip steps
- Destructive actions require explicit user confirmation
- Always include a rollback plan for production changes
