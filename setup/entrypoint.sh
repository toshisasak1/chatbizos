#!/usr/bin/env bash
set -eu

OPENCLAW_HOME="${OPENCLAW_HOME:-/opt/chatbizos}"
WORKSPACE_DIR="${WORKSPACE_DIR:-$OPENCLAW_HOME/workspace}"
CONFIG_DIR="$OPENCLAW_HOME/config"
TEMPLATE_DIR="$OPENCLAW_HOME/workspace-template"
CRON_FILE="$CONFIG_DIR/generated-cron.yaml"
OPENCLAW_CONFIG="$CONFIG_DIR/generated-openclaw-config.json"

mkdir -p "$WORKSPACE_DIR"

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

copy_if_missing "$TEMPLATE_DIR" "$WORKSPACE_DIR"

for agent in producer concept conversation builder compliance; do
  mkdir -p "$WORKSPACE_DIR/.agents/$agent"
  cp "$OPENCLAW_HOME/agents/$agent/SOUL.md" "$WORKSPACE_DIR/.agents/$agent/SOUL.md"
done

CHAT_CHANNEL="${CHAT_CHANNEL:-discord}"
DISCORD_ENABLED=false
SLACK_ENABLED=false
if [ "$CHAT_CHANNEL" = "discord" ]; then
  DISCORD_ENABLED=true
elif [ "$CHAT_CHANNEL" = "slack" ]; then
  SLACK_ENABLED=true
fi

cat > "$OPENCLAW_CONFIG" <<EOF
{
  "gateway": {
    "bind": "0.0.0.0",
    "port": ${OPENCLAW_PORT:-18789}
  },
  "runtime": {
    "toolProfile": "full",
    "agentToAgent": true
  },
  "memory": {
    "search": {
      "fts": true
    }
  },
  "plugins": {
    "entries": {
      "discord": {
        "enabled": $DISCORD_ENABLED,
        "botToken": "${DISCORD_BOT_TOKEN:-}",
        "guildId": "${DISCORD_GUILD_ID:-}",
        "channelId": "${DISCORD_CHANNEL_ID:-}"
      },
      "slack": {
        "enabled": $SLACK_ENABLED,
        "botToken": "${SLACK_BOT_TOKEN:-}",
        "appToken": "${SLACK_APP_TOKEN:-}",
        "channelId": "${SLACK_CHANNEL_ID:-}"
      }
    }
  },
  "agents": [
    {"id": "producer", "label": "Producer", "workspace": "$WORKSPACE_DIR", "soul": "$OPENCLAW_HOME/agents/producer/SOUL.md"},
    {"id": "concept", "label": "Concept", "workspace": "$WORKSPACE_DIR", "soul": "$OPENCLAW_HOME/agents/concept/SOUL.md"},
    {"id": "conversation", "label": "Conversation", "workspace": "$WORKSPACE_DIR", "soul": "$OPENCLAW_HOME/agents/conversation/SOUL.md"},
    {"id": "builder", "label": "Builder", "workspace": "$WORKSPACE_DIR", "soul": "$OPENCLAW_HOME/agents/builder/SOUL.md"},
    {"id": "compliance", "label": "Compliance", "workspace": "$WORKSPACE_DIR", "soul": "$OPENCLAW_HOME/agents/compliance/SOUL.md"}
  ]
}
EOF

cp "$CONFIG_DIR/cron.yaml" "$CRON_FILE"

echo "ChatBizOS entrypoint prepared workspace at $WORKSPACE_DIR"
echo "Generated config: $OPENCLAW_CONFIG"
echo "Generated cron: $CRON_FILE"

exec openclaw gateway start
