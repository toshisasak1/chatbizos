#!/usr/bin/env bash
set -eu

OPENCLAW_HOME="${OPENCLAW_HOME:-/opt/chatbizos}"
WORKSPACE_DIR="${WORKSPACE_DIR:-$OPENCLAW_HOME/workspace}"
OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-$OPENCLAW_HOME/.openclaw}"
CONFIG_DIR="$OPENCLAW_HOME/config"
TEMPLATE_DIR="$OPENCLAW_HOME/workspace-template"
RUNTIME_DIR="$OPENCLAW_STATE_DIR/runtime"
OPENCLAW_CONFIG="$RUNTIME_DIR/generated-openclaw-config.json"
GATEWAY_TOKEN_FILE="$RUNTIME_DIR/generated-gateway-token.txt"
AGENT_IDS="producer concept conversation builder compliance"

mkdir -p "$WORKSPACE_DIR" "$OPENCLAW_STATE_DIR" "$CONFIG_DIR" "$RUNTIME_DIR"

copy_if_missing() {
  src_dir="$1"
  dst_dir="$2"
  if [ ! -d "$dst_dir" ]; then
    mkdir -p "$dst_dir"
  fi
  (cd "$src_dir" && find . -mindepth 1 -print) | while IFS= read -r item; do
    src="$src_dir/$item"
    dst="$dst_dir/$item"
    if [ -d "$src" ]; then
      mkdir -p "$dst"
    elif [ ! -e "$dst" ]; then
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
    fi
  done
}

link_shared_workspace_into_agent_workspace() {
  agent_workspace="$1"
  mkdir -p "$agent_workspace"
  find "$WORKSPACE_DIR" -mindepth 1 -maxdepth 1 | while IFS= read -r src; do
    name="$(basename "$src")"
    case "$name" in
      SOUL.md|AGENTS.md|TOOLS.md|IDENTITY.md|USER.md|HEARTBEAT.md|BOOTSTRAP.md)
        continue
        ;;
    esac
    dst="$agent_workspace/$name"
    if [ ! -e "$dst" ]; then
      ln -s "$src" "$dst"
    fi
  done
}

ensure_gateway_token() {
  if [ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]; then
    printf "%s" "$OPENCLAW_GATEWAY_TOKEN" > "$GATEWAY_TOKEN_FILE"
    return
  fi

  if [ -s "$GATEWAY_TOKEN_FILE" ]; then
    OPENCLAW_GATEWAY_TOKEN="$(cat "$GATEWAY_TOKEN_FILE")"
    export OPENCLAW_GATEWAY_TOKEN
    return
  fi

  OPENCLAW_GATEWAY_TOKEN="$(
    node -e "process.stdout.write(require('node:crypto').randomBytes(24).toString('hex'))"
  )"
  export OPENCLAW_GATEWAY_TOKEN
  printf "%s" "$OPENCLAW_GATEWAY_TOKEN" > "$GATEWAY_TOKEN_FILE"
}

copy_if_missing "$TEMPLATE_DIR" "$WORKSPACE_DIR"
ensure_gateway_token

for agent in $AGENT_IDS; do
  agent_workspace="$OPENCLAW_STATE_DIR/workspaces/$agent"
  agent_dir="$OPENCLAW_STATE_DIR/agents/$agent/agent"
  mkdir -p "$agent_workspace" "$agent_dir"
  cp "$OPENCLAW_HOME/agents/$agent/SOUL.md" "$agent_workspace/SOUL.md"
  link_shared_workspace_into_agent_workspace "$agent_workspace"
done

node - "$OPENCLAW_CONFIG" <<'NODE'
const fs = require("node:fs");
const path = require("node:path");

const outPath = process.argv[2];
const env = process.env;

const workspaceRoot = env.WORKSPACE_DIR || "/opt/chatbizos/workspace";
const stateDir = env.OPENCLAW_STATE_DIR || "/opt/chatbizos/.openclaw";
const llmProvider = (env.LLM_PROVIDER || "openai").trim();
const port = Number(env.OPENCLAW_PORT || "18789");
const gatewayBind = (env.OPENCLAW_GATEWAY_BIND || "lan").trim();
const gatewayToken = (env.OPENCLAW_GATEWAY_TOKEN || "").trim();

const defaultModelByProvider = {
  openai: "openai/gpt-4o",
  anthropic: "anthropic/claude-sonnet-4-5-20250929",
  local: "local/llama3",
};

const agentDefs = [
  ["producer", "Producer"],
  ["concept", "Concept"],
  ["conversation", "Conversation"],
  ["builder", "Builder"],
  ["compliance", "Compliance"],
];

const config = {
  gateway: {
    mode: "local",
    bind: gatewayBind,
    port,
    auth: {
      mode: "token",
      token: gatewayToken,
    },
  },
  tools: {
    profile: "full",
    agentToAgent: {
      enabled: true,
      allow: agentDefs.map(([id]) => id),
    },
    sessions: {
      visibility: "all",
    },
  },
  session: {
    agentToAgent: {
      maxPingPongTurns: 3,
    },
  },
  cron: {
    enabled: true,
    sessionRetention: "24h",
  },
  agents: {
    defaults: {
      model: {
        primary: defaultModelByProvider[llmProvider] || defaultModelByProvider.openai,
      },
    },
    list: agentDefs.map(([id, name], index) => ({
      id,
      name,
      default: index === 0,
      workspace: path.join(stateDir, "workspaces", id),
      agentDir: path.join(stateDir, "agents", id, "agent"),
      model: defaultModelByProvider[llmProvider] || defaultModelByProvider.openai,
      identity: {
        name,
      },
    })),
  },
  channels: {
    defaults: {
      groupPolicy: "allowlist",
    },
  },
};

if (llmProvider === "local") {
  config.models = {
    mode: "merge",
    providers: {
      local: {
        baseUrl: (env.LOCAL_LLM_ENDPOINT || "http://localhost:11434/v1").replace(/\/$/, ""),
        api: "openai-completions",
        models: [
          {
            id: "llama3",
            name: "Llama 3",
            reasoning: false,
            input: ["text"],
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
            contextWindow: 8192,
            maxTokens: 4096,
          },
        ],
      },
    },
  };
}

if ((env.CHAT_CHANNEL || "discord").trim() === "discord") {
  const guildId = (env.DISCORD_GUILD_ID || "").trim();
  const channelId = (env.DISCORD_CHANNEL_ID || "").trim();
  config.channels.discord = {
    enabled: true,
    token: (env.DISCORD_BOT_TOKEN || "").trim(),
    dmPolicy: "pairing",
    groupPolicy: "allowlist",
    historyLimit: 20,
    threadBindings: {
      enabled: true,
      idleHours: 24,
      maxAgeHours: 0,
      spawnSubagentSessions: true,
    },
  };
  if (guildId) {
    config.channels.discord.guilds = {
      [guildId]: {
        requireMention: false,
        ...(channelId
          ? {
              channels: {
                [channelId]: {
                  allow: true,
                  requireMention: false,
                },
              },
            }
          : {}),
      },
    };
  }
} else {
  const slackChannelId = (env.SLACK_CHANNEL_ID || "").trim();
  config.channels.slack = {
    enabled: true,
    botToken: (env.SLACK_BOT_TOKEN || "").trim(),
    appToken: (env.SLACK_APP_TOKEN || "").trim(),
    dmPolicy: "pairing",
    groupPolicy: "allowlist",
    historyLimit: 50,
    allowBots: false,
    thread: {
      historyScope: "thread",
      inheritParent: false,
    },
  };
  if (slackChannelId) {
    config.channels.slack.channels = {
      [slackChannelId]: {
        allow: true,
        requireMention: false,
        allowBots: false,
      },
    };
  }
}

fs.writeFileSync(outPath, JSON.stringify(config, null, 2) + "\n", "utf8");
NODE

export OPENCLAW_CONFIG_PATH="$OPENCLAW_CONFIG"

echo "ChatBizOS entrypoint prepared shared workspace at $WORKSPACE_DIR"
echo "ChatBizOS entrypoint prepared agent state at $OPENCLAW_STATE_DIR"
echo "Generated config: $OPENCLAW_CONFIG"
if [ -f "$CONFIG_DIR/cron.yaml" ]; then
  echo "Cron templates available at $CONFIG_DIR/cron.yaml"
  echo "Register scheduled jobs with: /opt/chatbizos/setup/register-cron.sh"
fi

exec openclaw gateway run
