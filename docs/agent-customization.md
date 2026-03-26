# Agent Customization

## How SOUL.md Files Work

Each agent is primarily shaped by its `SOUL.md` file. The file defines the role, priorities, quality standards, escalation rules, and working style of that agent.

Changing a `SOUL.md` file changes how that agent behaves.

## Modifying Agent Behavior

When modifying an agent:
1. Start with the smallest change that solves the problem.
2. Keep the role boundary clear.
3. Update examples, quality rules, and escalation logic together.
4. Avoid embedding business-specific secrets or environment-specific assumptions.

## Adding New Agents

To add a new agent:
1. Create a new directory under `agents/`.
2. Add a `SOUL.md` file.
3. Update `config/openclaw-config.json` generation logic.
4. Decide how the new agent fits into the Producer task loop.
5. Update the documentation and examples.

## Removing Agents

To remove an agent:
1. Delete or archive its directory under `agents/`.
2. Remove it from the generated OpenClaw config.
3. Update any task queue conventions that mention it.
4. Review whether another agent needs expanded scope.

## Creating Domain-Specific Agent Configurations

A good domain-specific customization should:
- preserve the general operating pattern,
- add industry-relevant checklists,
- change examples and heuristics,
- avoid overfitting to one narrow use case unless that is the goal.

Example domains:
- e-commerce
- SaaS
- consulting
- education products
- local service businesses
