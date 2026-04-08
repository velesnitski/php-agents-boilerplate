# PHP Team Agent System

Multi-agent system for PHP backend development, database management, and operations.

## Quick Start

Describe your task naturally – the Router agent will classify it and dispatch to the right specialists:

```
> Add a paginated endpoint for user activity logs
```

To invoke the router directly: use `@router` in Claude Code.

## Agents

| Agent | Model | Role |
|-------|-------|------|
| `router` | sonnet | Task dispatcher and orchestrator |
| `backend-dev` | opus | PHP code, APIs, business logic |
| `dba` | opus | Schema, migrations, query optimization |
| `ops` | opus | Deploy, infra, monitoring |
| `qa` | sonnet | Testing and verification |

## Routing Paths

- **Complex**: DBA (if schema) → Backend Dev → QA → User review → Ops (deploy)
- **Simple**: Backend Dev → QA → User review → Ops
- **DB-only**: DBA → User confirmation
- **Ops-only**: Ops → Verify

## Task State Files

Each task creates `.tasks/YYMMDD-HHMM-slug.md` – agents append their sections sequentially. This preserves original outputs and avoids information loss.

## Rules

- Destructive operations require explicit user confirmation
- User reviews code before deploy
- Agents stay within their scope – see "What you do NOT do" in each agent
- All bash commands should use `rtk` proxy when available for token savings
- Every architectural decision must include an ADR in `docs/adr/`

## Skills

| Skill | Used by | Purpose |
|-------|---------|---------|
| `work-conventions` | all agents | Git, code style, ADR, sensitive data rules |
| `php-stack` | backend-dev | Laravel 11 / PHP 8.2 structure, patterns, tooling |
| `repository-pattern` | backend-dev | Contracts + repositories, DI binding |
| `testing-strategy` | backend-dev, qa | PHPUnit conventions, feature vs unit, coverage |
| `db-operations` | dba | Migration safety, optimization, backups |
| `docker-workflow` | ops, backend-dev | Docker Compose multi-env setup, Makefile |
| `server-infra` | ops | Docker services, logs, health checks |
| `deploy-procedures` | ops | Makefile-driven deploy, staging SSH, rollback |
| `adr-documentation` | all agents | When and how to write ADRs |

## Customization

To adapt for your project:
1. Update `skills/php-stack.md` with your framework version and project structure
2. Update `skills/server-infra.md` with your Docker service names and ports
3. Update `skills/deploy-procedures.md` with your deploy workflow and hosts
4. Update `skills/docker-workflow.md` with your Docker Compose services
5. Add project-specific skills as needed (e.g., `api-contracts.md`, `queue-architecture.md`)
