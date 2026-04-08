# PHP Team Agents for Claude Code

A multi-agent system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that simulates a PHP backend team with specialized roles: backend developer, DBA, ops engineer, and QA.

Drop this configuration into any PHP/Laravel project and Claude Code will route tasks to the right specialist agent automatically.

## Agents

| Agent | Model | Responsibility |
|-------|-------|----------------|
| **Router** | Sonnet | Classifies tasks, dispatches to agents, narrates progress |
| **Backend Dev** | Opus | PHP code, APIs, business logic, refactoring |
| **DBA** | Opus | Schema design, migrations, query optimization |
| **Ops** | Opus | Deployments, infrastructure, monitoring, incident response |
| **QA** | Sonnet | Testing, regression checks, verification |

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
git clone https://github.com/user/php-agents.git /tmp/php-agents
cp -r /tmp/php-agents/.claude .claude
cp /tmp/php-agents/CLAUDE.md CLAUDE.md
rm -rf /tmp/php-agents
```

Or copy manually:

```
your-project/
├── .claude/
│   ├── agents/
│   │   ├── router.md
│   │   ├── backend-dev.md
│   │   ├── dba.md
│   │   ├── ops.md
│   │   └── qa.md
│   └── skills/
│       ├── work-conventions.md
│       ├── php-stack.md
│       ├── db-operations.md
│       ├── server-infra.md
│       └── deploy-procedures.md
├── CLAUDE.md
└── ... your project files
```

### 2. Customize for your project

Update these files with your project specifics:

- **`skills/php-stack.md`** – framework version, project structure, key commands
- **`skills/server-infra.md`** – server details, log paths, service names
- **`skills/deploy-procedures.md`** – your deploy workflow, environments, rollback steps
- **`skills/work-conventions.md`** – branch naming, commit conventions, review process

### 3. Run Claude Code

```bash
claude
```

Then describe your task naturally:

```
> Add a new /api/users/{id}/activity endpoint that returns the last 30 days of user activity, paginated
```

The Router will classify this as a complex task and chain: DBA (if schema needed) → Backend Dev → QA → your review → Ops (deploy).

## Skills

Skills are shared knowledge bases that agents reference:

| Skill | Used By | Purpose |
|-------|---------|---------|
| `work-conventions` | All agents | Git workflow, code review checklist, communication standards |
| `php-stack` | Backend Dev | Laravel structure, key commands, coding patterns |
| `db-operations` | DBA | Migration safety, query optimization, backup procedures |
| `server-infra` | Ops | Service management, log locations, health checks |
| `deploy-procedures` | Ops | Deploy steps, post-deploy verification, rollback |

## Safety Guardrails

- **Destructive operations** (DROP, DELETE, rm -rf) require explicit user confirmation
- **Deploys** require user code review before proceeding
- **Agents stay in scope** – Backend Dev won't touch migrations, DBA won't modify app code
- **Rollback plans** are required for all production changes
- **No hardcoded credentials** – enforced via code review checklist

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
---
```

Then add routing rules in `router.md`.

### Adding a new skill

Create `.claude/skills/your-skill.md`:

```yaml
---
name: your-skill
description: What knowledge this provides
---
```

Reference it in the agent's `skills:` frontmatter.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A PHP/Laravel project (adaptable to other PHP frameworks)

## License

MIT
