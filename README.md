# ChatBizOS

ChatBizOS is an open-source multi-agent business building framework built on OpenClaw. It gives non-technical entrepreneurs a pre-configured AI team they can talk to through Discord or Slack. The team helps turn a business idea into strategy, content, implementation plans, and structured progress.

## What is ChatBizOS

ChatBizOS packages five specialized agents into a single workflow:
- **Producer** orchestrates the work and keeps progress visible.
- **Concept** designs the business strategy.
- **Conversation** creates messaging and growth assets.
- **Builder** defines practical implementation steps.
- **Compliance** flags legal and platform risks.

The result is a workspace of structured markdown files that shows what has been decided, what is being worked on, and what needs human approval.

## Features

- Pre-configured 5-agent business creation team
- Discord and Slack support for chat-based workflows
- OpenAI, Anthropic, and local LLM configuration
- Workspace template for strategy, research, growth, implementation, and validation
- Cron-based morning briefing, nightly review, and weekly progress reporting
- Agent SOUL.md files designed for domain-agnostic business building
- Setup wizard for generating `.env` configuration
- Docker-based local deployment

## Quick Start (Docker)

```bash
git clone https://github.com/<owner>/chatbizos
cd chatbizos
cp .env.example .env
# Edit .env with your API keys and chat credentials
docker compose up -d
```

After the container starts, use your configured Discord or Slack channel to talk to the Producer agent.

## Architecture

```text
User (phone or desktop)
        |
        v
Discord / Slack
        |
        v
OpenClaw Gateway
        |
        v
Producer ----> Concept
   |              |
   |              v
   |--------> Conversation
   |              |
   |              v
   |--------> Builder
   |              |
   |              v
   +--------> Compliance
        |
        v
Workspace files + logs
```

## Agents

### Producer
The orchestrator. Reads status, prioritizes tasks, delegates work, evaluates output quality, updates logs, and asks the human for decisions when needed.

### Concept
The business strategist. Defines the market, offer, ICP, positioning, pricing approach, and research direction.

### Conversation
The growth and content lead. Creates messaging, content, customer scripts, and brand voice assets.

### Builder
The implementation lead. Recommends practical tool stacks and writes step-by-step setup instructions for non-engineers.

### Compliance
The legal and risk checker. Flags privacy, advertising, platform, and consumer protection risks and always escalates them for human review.

## Configuration

Key configuration files:
- `config/chatbizos.yaml` - high-level project, agent, provider, and channel settings
- `config/openclaw-config.json` - generated OpenClaw runtime configuration template
- `config/cron.yaml` - scheduled briefings and reviews
- `.env` - secrets and deployment-specific environment variables

## Documentation

- `docs/getting-started.md`
- `docs/architecture.md`
- `docs/agent-customization.md`
- `docs/llm-providers.md`
- `docs/troubleshooting.md`

## Contributing

Contributions are welcome. Please read `CONTRIBUTING.md` before opening a pull request.

## License

MIT. See `LICENSE`.
