# Getting Started

This guide is written for non-engineers who want to run ChatBizOS with as little setup friction as possible.

## 1. Prerequisites

You need:
- Docker Desktop or Docker Engine
- A Discord or Slack account
- An API key for your LLM provider
- Basic ability to edit a `.env` file

## 2. Getting an API Key

### OpenAI
1. Create or sign in to your OpenAI account.
2. Open the API dashboard.
3. Generate an API key.
4. Copy the key into your `.env` file.

Screenshot description: The API keys page shows a button to create a new secret key and a list of existing keys.

### Anthropic
1. Create or sign in to your Anthropic account.
2. Open the API keys section.
3. Generate a new key.
4. Copy the key into your `.env` file.

Screenshot description: The Anthropic console shows key management with a create button and a masked key list.

## 3. Creating a Discord Bot or Slack App

### Discord
1. Go to the Discord Developer Portal.
2. Create a new application.
3. Add a bot user.
4. Copy the bot token.
5. Invite the bot to your server with the needed permissions.
6. Copy the server ID and channel ID.

### Slack
1. Go to the Slack API dashboard.
2. Create a new app.
3. Add a bot token scope suitable for messaging.
4. Install the app to your workspace.
5. Copy the bot token, app token, and target channel ID.

## 4. Clone the Repository

```bash
git clone https://github.com/<owner>/chatbizos
cd chatbizos
```

## 5. Run the Setup Wizard

```bash
./setup/setup.sh
```

The wizard asks for your provider, key, chat channel, channel credentials, and timezone. It writes a `.env` file for you.

## 6. Start with Docker Compose

```bash
docker compose up -d
```

This builds the container, prepares the workspace, generates the OpenClaw config, and starts the gateway.

## 7. First Conversation with the Bot

Open your configured Discord or Slack channel and send a simple message such as:
- “I want to start a handmade candle business.”
- “Help me validate a consulting offer.”
- “I have an idea for a niche SaaS product.”

The Producer agent should start organizing the work and clarifying what matters first.

## 8. Understanding the Workspace

The `workspace/` directory is where business progress is stored.

Important files:
- `STATUS.md` - current phase and blockers
- `MILESTONES.md` - major checkpoints
- `06_operations/task_queue.md` - current work queue
- `06_operations/decision_log.md` - key decisions
- `07_validation/compliance_log.md` - risk notes and required review

## 9. Common Issues and Fixes

### Container starts but the bot does not respond
- Check your `.env` values.
- Confirm the bot has access to the target channel.
- Review `docs/troubleshooting.md`.

### The workspace is empty
- Confirm the container can write to `./workspace`.
- Rebuild and restart the container.

### LLM errors appear
- Re-check your API key.
- Confirm the provider name in `.env` matches the expected values.
