#!/usr/bin/env bash
set -eu

CONTAINER_NAME="${CHATBIZOS_CONTAINER_NAME:-chatbizos}"
MODE="${1:-}"

if [ "$MODE" != "--inside" ] && command -v docker >/dev/null 2>&1; then
  if docker ps --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
    docker exec "$CONTAINER_NAME" sh -lc "/opt/chatbizos/setup/validate.sh --inside"
    exit $?
  fi
fi

if [ -f ./.env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

OPENCLAW_HOME="${OPENCLAW_HOME:-/opt/chatbizos}"
OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-$OPENCLAW_HOME/.openclaw}"
WORKSPACE_DIR="${WORKSPACE_DIR:-$OPENCLAW_HOME/workspace}"
PORT="${OPENCLAW_PORT:-18789}"
GENERATED_CONFIG="${OPENCLAW_HOME}/config/generated-openclaw-config.json"
STATUS_GATEWAY="FAIL"
STATUS_CHANNEL="FAIL"
STATUS_LLM="FAIL"
STATUS_WORKSPACE="FAIL"
STATUS_CRON="FAIL"
DETAIL_CHANNEL="not checked"
DETAIL_LLM="not checked"
DETAIL_CRON="not checked"

if [ -f "$GENERATED_CONFIG" ]; then
  export OPENCLAW_CONFIG_PATH="$GENERATED_CONFIG"
fi

if [ -d "$WORKSPACE_DIR" ] && [ -f "$WORKSPACE_DIR/STATUS.md" ]; then
  STATUS_WORKSPACE="OK"
fi

if command -v curl >/dev/null 2>&1; then
  if curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null 2>&1 || curl -fsS "http://127.0.0.1:$PORT" >/dev/null 2>&1; then
    STATUS_GATEWAY="OK"
  fi
fi

if command -v openclaw >/dev/null 2>&1; then
  if openclaw channels status --probe >/tmp/chatbizos-channels-status.txt 2>&1; then
    STATUS_CHANNEL="OK"
    DETAIL_CHANNEL="$(tr '\n' ' ' </tmp/chatbizos-channels-status.txt | sed 's/[[:space:]]\+/ /g' | cut -c1-180)"
  elif [ "${CHAT_CHANNEL:-discord}" = "discord" ] && [ -n "${DISCORD_BOT_TOKEN:-}" ]; then
    STATUS_CHANNEL="CONFIGURED"
    DETAIL_CHANNEL="Discord token present but live probe failed"
  elif [ "${CHAT_CHANNEL:-discord}" = "slack" ] && [ -n "${SLACK_BOT_TOKEN:-}" ] && [ -n "${SLACK_APP_TOKEN:-}" ]; then
    STATUS_CHANNEL="CONFIGURED"
    DETAIL_CHANNEL="Slack tokens present but live probe failed"
  else
    DETAIL_CHANNEL="Channel credentials missing"
  fi

  if openclaw cron list --all --json >/tmp/chatbizos-cron-status.json 2>/tmp/chatbizos-cron-status.err; then
    cron_count="$(
      node -e "const fs=require('node:fs'); const data=JSON.parse(fs.readFileSync(process.argv[1],'utf8')); process.stdout.write(String((data.jobs||[]).length));" \
        /tmp/chatbizos-cron-status.json
    )"
    if [ "${cron_count:-0}" -gt 0 ]; then
      STATUS_CRON="OK"
      DETAIL_CRON="$cron_count scheduled jobs registered"
    else
      STATUS_CRON="CONFIGURED"
      DETAIL_CRON="No cron jobs registered yet. Run ./setup/register-cron.sh after the gateway starts."
    fi
  else
    DETAIL_CRON="Cron scheduler could not be queried"
  fi
fi

case "${LLM_PROVIDER:-openai}" in
  openai)
    if command -v curl >/dev/null 2>&1 && [ -n "${OPENAI_API_KEY:-}" ]; then
      if curl -fsS -H "Authorization: Bearer ${OPENAI_API_KEY}" "https://api.openai.com/v1/models" >/dev/null 2>&1; then
        STATUS_LLM="OK"
        DETAIL_LLM="OpenAI models endpoint reachable"
      else
        STATUS_LLM="CONFIGURED"
        DETAIL_LLM="OpenAI key present but connectivity check failed"
      fi
    else
      DETAIL_LLM="OpenAI key missing"
    fi
    ;;
  anthropic)
    if command -v curl >/dev/null 2>&1 && [ -n "${ANTHROPIC_API_KEY:-}" ]; then
      if curl -fsS \
        -H "x-api-key: ${ANTHROPIC_API_KEY}" \
        -H "anthropic-version: 2023-06-01" \
        "https://api.anthropic.com/v1/models" >/dev/null 2>&1; then
        STATUS_LLM="OK"
        DETAIL_LLM="Anthropic models endpoint reachable"
      else
        STATUS_LLM="CONFIGURED"
        DETAIL_LLM="Anthropic key present but connectivity check failed"
      fi
    else
      DETAIL_LLM="Anthropic key missing"
    fi
    ;;
  local)
    endpoint="${LOCAL_LLM_ENDPOINT:-http://localhost:11434}"
    endpoint="${endpoint%/}"
    if command -v curl >/dev/null 2>&1; then
      if curl -fsS "${endpoint}/api/tags" >/dev/null 2>&1 || curl -fsS "${endpoint}/v1/models" >/dev/null 2>&1; then
        STATUS_LLM="OK"
        DETAIL_LLM="Local model endpoint reachable"
      else
        STATUS_LLM="CONFIGURED"
        DETAIL_LLM="Local endpoint configured but not reachable"
      fi
    fi
    ;;
esac

echo "ChatBizOS validation summary"
echo "- OpenClaw gateway: $STATUS_GATEWAY"
echo "- Chat channel: $STATUS_CHANNEL"
echo "  $DETAIL_CHANNEL"
echo "- LLM connectivity: $STATUS_LLM"
echo "  $DETAIL_LLM"
echo "- Scheduled jobs: $STATUS_CRON"
echo "  $DETAIL_CRON"
echo "- Workspace directory: $STATUS_WORKSPACE"
echo "  ${WORKSPACE_DIR}"
