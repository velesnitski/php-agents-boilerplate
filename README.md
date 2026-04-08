# PHP Team Agents for Claude Code

A multi-agent system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that simulates a PHP backend team with specialized roles: backend developer, DBA, ops engineer, and QA.

Drop this configuration into any PHP/Laravel project and Claude Code will route tasks to the right specialist agent automatically.

## Agents

| Agent | Model | Responsibility |
|-------|-------|----------------|
| **Router** | Haiku | Classifies tasks, dispatches to agents, narrates progress |
| **Backend Dev** | Opus | PHP code, APIs, business logic, refactoring |
| **DBA** | Opus | Schema design, migrations, query optimization |
| **Ops** | Sonnet | Deployments, infrastructure, monitoring, incident response |
| **QA** | Haiku | Testing, regression checks, verification |

## How It Works

```
User → Router → Agent(s) → User Review → Deploy
```

The Router classifies your request and picks the right workflow:

- **Complex tasks** (new feature, major refactor): DBA → Backend Dev → QA → User review → Ops
- **Simple tasks** (bug fix, small change): Backend Dev → QA → User review → Ops
- **DB-only tasks** (query optimization, data fix): DBA → User confirmation
- **Ops-only tasks** (deploy, infra): Ops → Verify
- **Investigations** (debug, analysis): routed to the most relevant agent

Each agent produces structured output and stays within its defined scope. Agents explicitly document what they do *not* do, preventing scope creep.

## Installation

### 1. Clone into your project

```bash
# From your PHP/Laravel project root
git clone https://github.com/velesnitski/php-agents-boilerplate.git /tmp/php-agents
cp -r /tmp/php-agents/.claude .claude
cp /tmp/php-agents/CLAUDE.md CLAUDE.md
rm -rf /tmp/php-agents
```

Or copy manually:

```
your-project/
├── .claude/
│   ├── agents/
│   │   ├── router.md          # task dispatcher
│   │   ├── backend-dev.md     # PHP developer
│   │   ├── dba.md             # database architect
│   │   ├── ops.md             # DevOps/SRE
│   │   └── qa.md              # QA engineer
│   └── skills/                         # Agent Skills (Anthropic SKILL.md standard)
│       ├── work-conventions/SKILL.md   # git, code style, ADR, security
│       ├── php-stack/SKILL.md          # Laravel 11 / PHP 8.2 reference
│       ├── testing-strategy/SKILL.md   # PHPUnit conventions
│       ├── db-operations/SKILL.md      # migration safety, optimization
│       ├── docker-workflow/SKILL.md    # Docker Compose, deploy, rollback
│       ├── server-infra/SKILL.md       # Docker services, logs, health
│       ├── adr-documentation/SKILL.md  # architecture decision records
│       └── repository-pattern/SKILL.md # contracts + repositories (on-demand)
├── CLAUDE.md
└── ... your project files
```

### 2. Customize for your project

Update these files with your project specifics:

- **`skills/php-stack.md`** – framework version, project structure, key commands
- **`skills/server-infra.md`** – Docker service names, ports, log paths
- **`skills/deploy-procedures.md`** – your deploy workflow, environments, hosts
- **`skills/docker-workflow.md`** – your Docker Compose services and Makefile targets
- **`skills/work-conventions.md`** – branch naming, commit conventions, review process

### 3. Run Claude Code

Everything goes through the **Router** agent by default. Three ways to use it:

**Automatic** – just describe your task. CLAUDE.md instructs Claude to route via Router:

```bash
claude
> Add a new /api/users/{id}/activity endpoint that returns the last 30 days of user activity, paginated
```

**Explicit** – invoke the Router directly with `@router`:

```
> @router Fix the slow query on /api/orders
```

**CLI one-liner** – pass the task as an argument:

```bash
claude --agent router "Add pagination to the orders API"
```

All three end up in the same place – the Router classifies the task and chains the right agents (e.g. DBA → Backend Dev → QA → your review → Ops).

## Skills

Skills are shared knowledge bases that agents reference:

| Skill | Used By | Purpose |
|-------|---------|---------|
| `work-conventions` | All agents | Git workflow, code style (Pint/PHPStan), ADR, security |
| `php-stack` | Backend Dev | Laravel 11 / PHP 8.2 structure, patterns, tooling |
| `testing-strategy` | Backend Dev, QA | PHPUnit 11, feature vs unit, coverage, Allure reporting |
| `db-operations` | DBA | Migration safety, query optimization, backup/restore |
| `docker-workflow` | Ops | Docker Compose, Makefile, deploy, rollback (all-in-one) |
| `server-infra` | Ops | Docker services, logs, health checks, troubleshooting |
| `adr-documentation` | All agents | When and how to write Architecture Decision Records |
| `repository-pattern` | On-demand | Contracts + Repositories (loaded when needed, not by default) |

## Tech Stack (as configured)

- **PHP 8.2+** / **Laravel 11**
- **MySQL 8.0** – primary database
- **Redis 7.4** – cache and queues
- **Nginx** – web server
- **Docker Compose** – local development and staging
- **Makefile** – task runner (init, test, deploy, backup)
- **PHPUnit 11** – testing
- **Laravel Pint** – code style (PSR-12)
- **Larastan / PHPStan** – static analysis
- **Allure** – test reporting
- **MinIO** – S3-compatible object storage (local dev)

## Safety Guardrails

- **Destructive operations** (DROP, DELETE, rm -rf) require explicit user confirmation
- **Deploys** require user code review before proceeding
- **Agents stay in scope** – Backend Dev won't touch migrations, DBA won't modify app code
- **Rollback plans** are required for all production changes
- **No hardcoded credentials** – enforced via code review checklist
- **Sensitive data scan** – check for leaked tokens, IPs, domains before pushing

## Task State

Each task creates a state file in `.tasks/YYMMDD-HHMM-slug.md`. Agents append their sections sequentially, preserving original outputs and maintaining a full audit trail.

## Customization

### Adding a new agent

Create `.claude/agents/your-agent.md`:

```yaml
---
name: your-agent
description: What this agent does
model: opus  # or sonnet
tools: Read, Write, Edit, Glob, Grep, Bash
skills:
  - relevant-skill
  - work-conventions
---
```

Then add routing rules in `router.md`.

### Adding a new skill

Create `.claude/skills/your-skill/SKILL.md` (follows [Anthropic's Agent Skills standard](https://agentskills.io)):

```yaml
---
name: your-skill
description: What knowledge this provides (max 250 chars)
user-invocable: false    # background knowledge, not a slash command
---

# Skill content here
```

Reference it in the agent's `skills:` frontmatter. The directory can also contain supporting files (examples, scripts, templates).

### Adapting for other frameworks

The agent definitions (router, dba, ops, qa) are framework-agnostic. To adapt for Symfony, Yii, or CodeIgniter:

1. Replace `skills/php-stack.md` with your framework's structure and commands
2. Update `skills/deploy-procedures.md` with your deploy workflow
3. Adjust `skills/testing-strategy.md` for your test runner (PHPSpec, Codeception, etc.)

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A PHP/Laravel project (adaptable to other PHP frameworks)
- Docker and Docker Compose (for the default infrastructure setup)

## License

MIT
