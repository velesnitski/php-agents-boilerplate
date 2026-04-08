# Contributing

Contributions are welcome! Here's how to help.

## What to contribute

- **New agents** – specialist roles (e.g., frontend dev, security auditor, API designer)
- **New skills** – knowledge bases for specific stacks or tools
- **Improvements** – better prompts, routing logic, safety guardrails
- **Adaptations** – configs for other PHP frameworks (Symfony, Yii, CodeIgniter)

## How to contribute

1. Fork the repository
2. Create a branch: `feature/your-change`
3. Make your changes
4. Test with Claude Code on a real project
5. Submit a pull request

## Guidelines

- Keep agent definitions focused – one clear responsibility per agent
- Include "What you do NOT do" boundaries in every agent
- Skills should be framework-agnostic where possible
- All destructive operations must require user confirmation
- Use structured output formats for agent reports

## Agent structure

Every agent file must include:

```yaml
---
name: agent-name
description: one-line description
model: opus or sonnet
tools: list of tools
skills:
  - referenced-skills
---
```

Followed by: role description, workflow, output format, technical standards, and scope boundaries.

## Testing

There's no automated test suite – these are prompt configurations. Test your changes by:

1. Copying the config into a PHP project
2. Running Claude Code
3. Giving it tasks that exercise the changed agent
4. Verifying the routing, output format, and scope boundaries work correctly
