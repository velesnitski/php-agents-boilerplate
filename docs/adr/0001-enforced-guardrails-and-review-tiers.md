# ADR-0001: Enforced guardrails, risk-tiered review and provenance for the agent team

Date: 2026-10-26
Status: accepted

## Context

The boilerplate described its safety rules in prose: "destructive operations require explicit
user confirmation", "user reviews code before deploy", "agents stay within their scope". An
agent that reads those lines usually follows them; one that does not is stopped by nobody.
Reviewing a production system built with a comparable agent set-up showed what happens at
scale: human review fell to one in a hundred pull requests within three months, an
automated reviewer that could only comment became the reviewer of record, sensitive paths
(CI, infrastructure, auth, migrations) merged without a second reader, the few hard limits
that held were the ones a hook or a database constraint enforced, and nobody could say which
model, prompt or skill version had produced a change. Anthropic's own write-up of the same
problem (claude.dev, "Solving code review at Anthropic", October 2026) draws the line the
same way: the change sets the risk tier, low risk merges on automated checks, medium needs
one person, high needs two, and an agent's approval never fills a human slot.

## Decision

1. **Hooks enforce the hard rules.** `.claude/settings.json` registers a PreToolUse guard on
   every Bash call (`.claude/hooks/guard.sh`) that blocks deploy, non-local migration and
   destructive commands unless a fresh approval file exists, and a PostToolUse formatter on
   every edit (`.claude/hooks/format.sh`, Laravel Pint). Approvals are created by a person
   with `scripts/approve.sh <category> [proposal]`, last 15 minutes, and are gitignored.
2. **Proposals before mutations.** The Ops agent writes a proposal file (commands, hosts,
   rollback) and stops; the person approves the proposal, which is what the guard checks.
   The deploy skill is marked `disable-model-invocation`, so an agent cannot load it by itself.
3. **Risk tiers set the human slots.** `scripts/risk-tier.mjs` classifies a change from the
   paths it touches and its size: high (always-human paths or more than 400 lines) needs two
   human approvals, medium one, low none. The Router states the tier before work starts; the
   `risk-tier` workflow enforces it as a required check and re-evaluates on every review.
4. **Automated review stays opt-in, read-only and non-approving.** `claude-review.yml` runs
   on a label or a member's `@claude review`, with a read-only tool list, a turn cap, a
   timeout and a mandatory verdict line. Its findings block through review threads, not
   through an approval it cannot give.
5. **Provenance travels with the change.** The PR template records tier, agents, skill
   versions, turns, cost and tests. Every skill carries a `version`, every agent a `maxTurns`,
   and `scripts/skills-lint.sh` keeps `skills.lock` current and fails when a skill names a tool
   or MCP server the harness does not have.

## Consequences

- An agent session can still do everything it could before; the difference is that the
  irreversible steps now wait for a person, and the wait is visible in the transcript.
- Approvals expire, so a stale "yes" from the morning does not authorise the afternoon.
- The always-human list and the size limit are the two knobs a team will argue about;
  both live in one file and the argument leaves a diff.
- The lint turns silent misconfiguration (a skill allowing a server that does not exist)
  into a failing check.
- None of this measures value; it records who and what produced a change so that a later
  review can.
