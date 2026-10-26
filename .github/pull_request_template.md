## Summary

<!-- What changed and why. Keep the PR under 400 changed lines unless it is a release promotion. -->

## Risk tier

<!-- Filled by `node scripts/risk-tier.mjs origin/main`, or by the Router before work started. -->
- Tier: low | medium | high
- Why:
- Human approvals required: 0 | 1 | 2 (an automated review never fills a human slot)

## Provenance

<!-- Every agent that touched this change records itself here; the person who directed the agent counts as one reviewer, never as the only one. -->
- Agents: router / backend-dev / dba / ops / qa (model per `.claude/agents/*.md`)
- Skills used (version from `skills.lock`):
- Turns and cost (from the session summary):
- Tests run:

## Checklist

- [ ] Tests cover the change, or "no testable surface" is stated above
- [ ] Migrations are reversible or marked irreversible with a reason
- [ ] ADR added in `docs/adr/` for any architectural decision
- [ ] No secrets, credentials or personal data in the diff
