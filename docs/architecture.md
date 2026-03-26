# Architecture

## System Stack Diagram

```text
User
  |
  v
Discord / Slack
  |
  v
OpenClaw Gateway
  |
  v
Producer ---> Concept
   |           |
   |           v
   |-------> Conversation
   |           |
   |           v
   |-------> Builder
   |           |
   |           v
   +-------> Compliance
  |
  v
Workspace markdown files
```

## Agent Communication Flow

ChatBizOS uses a star topology. Producer is the hub.

1. The human sends a message through Discord or Slack.
2. Producer interprets the request in context of the workspace.
3. Producer reads `STATUS.md` and `task_queue.md`.
4. Producer sends a `[TASK]` message to the right specialist.
5. The specialist updates the workspace files.
6. Producer evaluates the output and either accepts it or requests revision.
7. Important decisions or risks are surfaced back to the human.

## Task Loop Explanation

The default loop is:
- read status,
- identify next priority,
- delegate,
- review result,
- log decision,
- queue next action.

This keeps progress visible and prevents the team from operating as disconnected chatbots.

## Memory Architecture

ChatBizOS uses three layers of memory:

1. **Session memory** for recent conversation context
2. **Structured learning log** in `LEARNINGS.md`
3. **Documented state** in the workspace files themselves

The documented state is the most important because it survives sessions and can be reviewed by humans.

## Workspace Structure Explanation

- `01_strategy/` holds business direction and customer definitions.
- `02_research/` holds market evidence and competitor observations.
- `03_offer/` holds offer and pricing decisions.
- `04_growth/` holds marketing assets and scripts.
- `05_implementation/` holds tools and practical setup instructions.
- `06_operations/` holds queue, logs, and daily summaries.
- `07_validation/` holds experiments, metrics, rubric, and compliance review.
