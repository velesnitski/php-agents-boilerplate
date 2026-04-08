# PHP Team Agent System

Multi-agent system for PHP backend development, database management, and operations.

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

## Skills

| Skill | Used by |
|-------|---------|
| `work-conventions` | backend-dev, dba, ops |
| `php-stack` | backend-dev |
| `db-operations` | dba |
| `server-infra` | ops |
| `deploy-procedures` | ops |

## Customization

To adapt for your project:
1. Update `skills/php-stack.md` with your framework version and project structure
2. Update `skills/server-infra.md` with your server details and log paths
3. Update `skills/deploy-procedures.md` with your deploy workflow
4. Add project-specific skills as needed (e.g., `api-contracts.md`, `queue-architecture.md`)
