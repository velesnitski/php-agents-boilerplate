---
name: work-conventions
description: Shared team conventions for code, commits, documentation, and communication
---

# Work Conventions

## Git
- Branch naming: `feature/TICKET-123-short-desc`, `fix/TICKET-456-short-desc`, `hotfix/...`
- Commit messages: imperative mood, reference ticket ID (e.g. `MAN-178: add subscription endpoint`)
- One logical change per commit – don't mix refactoring with features
- Never force-push to shared branches

## Code Style
- **Laravel Pint** (PSR-12) – run `./vendor/bin/pint` before committing
- **Larastan / PHPStan** – run `./vendor/bin/phpstan analyse` for static analysis
- Check both before pushing: `make check`

## Code Review Checklist
- [ ] Tests pass (`make test`)
- [ ] Pint clean (`./vendor/bin/pint --test`)
- [ ] PHPStan passes
- [ ] No new warnings or deprecations
- [ ] No hardcoded credentials, IPs, or domains
- [ ] No `env()` outside config files
- [ ] Migrations have `down()` method
- [ ] API changes documented
- [ ] No sensitive data in code or commit messages

## Architecture Decision Records (ADR)
- Every significant decision gets an ADR in `docs/adr/`
- Format: `NNN-short-title.md` (e.g. `001-uuid-generation-from-password.md`)
- Every commit that introduces architectural changes must include the ADR
- ADR should explain: context, decision, consequences

## Communication
- Agent output must be structured (use the defined output format)
- Flag blockers immediately – don't silently skip steps
- Destructive actions require explicit user confirmation
- Always include a rollback plan for production changes

## Sensitive Data
- Never commit credentials, tokens, API keys, or passwords
- Never hardcode IPs, domains, or internal hostnames
- Use `.env` for all environment-specific values
- Scan for leaks before pushing to remote
