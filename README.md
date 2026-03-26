# ChatBizOS

[English](README.md) | [Japanese](README.ja.md)

ChatBizOS is an OpenClaw-based multi-agent system for people who want to build a business through chat instead of managing everything manually across docs, notes, and disconnected AI sessions.

You talk to one AI team in Discord or Slack. That team turns rough ideas into business strategy, research, positioning, content plans, implementation steps, and risk reviews, then stores the work in a structured workspace you can actually inspect.

## Why It Exists

Most people trying to build with AI still have to do the orchestration themselves:

- move context between chat threads
- repeat decisions every session
- keep strategy, content, and execution in sync
- remember what still needs human approval

ChatBizOS packages that operating layer into a reusable system.

## Who It Is For

- non-technical founders
- solo operators
- consultants building offers from scratch
- creators validating a product idea
- small teams that want a chat-first operating workflow

## What Happens After Your First Message

Example first message:

> "I want to start a handmade candle business."

What ChatBizOS does next:

1. Producer clarifies the goal, constraints, and current stage.
2. Concept drafts the business model, ICP, pricing options, and positioning.
3. Conversation creates brand and growth assets.
4. Builder outlines the minimum viable implementation path.
5. Compliance flags legal, privacy, ad, and platform risks for human review.

The result is not just a chat response. It is a working repository of decisions and deliverables inside your workspace.

## What You Get

- a 5-agent AI team with clear roles
- Discord and Slack support
- OpenAI, Anthropic, and local LLM support
- a workspace template for strategy, research, growth, implementation, and validation
- cron-driven morning briefings, nightly reviews, and weekly progress reports
- editable `SOUL.md` files for each agent
- Docker-based local deployment

## Workspace Output

ChatBizOS writes its progress into files you can review and edit:

```text
workspace/
  STATUS.md
  MILESTONES.md
  LEARNINGS.md
  01_strategy/
  02_research/
  03_offer/
  04_growth/
  05_implementation/
  06_operations/
  07_validation/
```

That structure is the point. It gives you continuity across sessions and keeps decisions visible.

## Quick Start (Docker)

```bash
git clone https://github.com/toshisasak1/chatbizos
cd chatbizos
cp .env.example .env
# Edit .env with your LLM and chat credentials
docker compose up -d
```

After the container starts, send a message in your configured Discord or Slack channel.

## Guided Setup

If you prefer prompts instead of editing `.env` manually:

```bash
./setup/setup.sh
```

Then validate the environment:

```bash
./setup/validate.sh
```

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
Owns orchestration. Reads status, chooses priorities, delegates work, evaluates outputs, updates logs, and decides when the human must step in.

### Concept
Owns business strategy. Works on market framing, ICP, offer design, pricing, positioning, and research synthesis.

### Conversation
Owns messaging and growth. Produces brand voice, content plans, scripts, and marketing assets.

### Builder
Owns implementation planning. Recommends practical tools and writes steps a non-engineer can actually follow.

### Compliance
Owns legal and risk review. Flags privacy, platform, advertising, and consumer-protection concerns. Compliance items are always escalated to a human.

## Configuration

Key files:

- `config/chatbizos.yaml`: project, agent, provider, and channel settings
- `config/openclaw-config.json`: OpenClaw runtime template
- `config/cron.yaml`: scheduled briefings and reviews
- `.env`: deployment-specific credentials and environment variables

## Documentation

- `docs/getting-started.md`
- `docs/architecture.md`
- `docs/agent-customization.md`
- `docs/llm-providers.md`
- `docs/troubleshooting.md`
- `README.ja.md` and `docs/ja/` for Japanese documentation

## Repository Structure

```text
agents/              Agent definitions
config/              Runtime and schedule configuration
docs/                Project documentation
examples/            Example use cases
setup/               Setup, entrypoint, and validation scripts
workspace-template/  Initial business workspace structure
```

## Contributing

Contributions are welcome. Read `CONTRIBUTING.md` before opening a pull request.

## License

MIT. See `LICENSE`.
