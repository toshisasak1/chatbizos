#!/usr/bin/env bash
set -eu

PORT="${OPENCLAW_PORT:-18789}"
WORKSPACE_DIR="${WORKSPACE_DIR:-./workspace}"
STATUS_GATEWAY="FAIL"
STATUS_CHANNEL="FAIL"
STATUS_LLM="FAIL"
STATUS_WORKSPACE="FAIL"

if command -v curl >/dev/null 2>&1; then
  if curl -fsS "http://127.0.0.1:$PORT" >/dev/null 2>&1 || curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; then
    STATUS_GATEWAY="OK"
  fi
fi

case "${CHAT_CHANNEL:-discord}" in
  discord)
    if [ -n "${DISCORD_BOT_TOKEN:-}" ] && [ -n "${DISCORD_CHANNEL_ID:-}" ]; then STATUS_CHANNEL="CONFIGURED"; fi
    ;;
  slack)
    if [ -n "${SLACK_BOT_TOKEN:-}" ] && [ -n "${SLACK_CHANNEL_ID:-}" ]; then STATUS_CHANNEL="CONFIGURED"; fi
    ;;
esac

case "${LLM_PROVIDER:-openai}" in
  openai)
    if [ -n "${OPENAI_API_KEY:-}" ]; then STATUS_LLM="CONFIGURED"; fi
    ;;
  anthropic)
    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then STATUS_LLM="CONFIGURED"; fi
    ;;
  local)
    if [ -n "${LOCAL_LLM_ENDPOINT:-}" ]; then STATUS_LLM="CONFIGURED"; fi
    ;;
esac

if [ -d "$WORKSPACE_DIR" ]; then
  STATUS_WORKSPACE="OK"
fi

echo "ChatBizOS validation summary"
echo "- OpenClaw gateway: $STATUS_GATEWAY"
echo "- Chat channel: $STATUS_CHANNEL"
echo "- LLM connectivity: $STATUS_LLM"
echo "- Workspace directory: $STATUS_WORKSPACE"
