#!/usr/bin/env bash
set -eu

CONTAINER_NAME="${CHATBIZOS_CONTAINER_NAME:-chatbizos}"
MODE="${1:-}"

if [ "$MODE" != "--inside" ] && command -v docker >/dev/null 2>&1; then
  if docker ps --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
    docker exec "$CONTAINER_NAME" sh -lc "/opt/chatbizos/setup/register-cron.sh --inside"
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
PORT="${OPENCLAW_PORT:-18789}"
GENERATED_CONFIG="${OPENCLAW_STATE_DIR}/runtime/generated-openclaw-config.json"
CRON_TEMPLATE="${OPENCLAW_HOME}/config/cron.yaml"
TMP_DIR="${TMPDIR:-/tmp}/chatbizos-cron"
CHANNEL_KIND="${CHAT_CHANNEL:-discord}"

mkdir -p "$TMP_DIR"

if [ -f "$GENERATED_CONFIG" ]; then
  export OPENCLAW_CONFIG_PATH="$GENERATED_CONFIG"
fi

if ! command -v openclaw >/dev/null 2>&1; then
  echo "openclaw CLI is not available in this environment." >&2
  exit 1
fi

if [ ! -f "$CRON_TEMPLATE" ]; then
  echo "Cron template not found: $CRON_TEMPLATE" >&2
  exit 1
fi

case "$CHANNEL_KIND" in
  discord)
    DESTINATION="${DISCORD_CHANNEL_ID:-}"
    ;;
  slack)
    DESTINATION="${SLACK_CHANNEL_ID:-}"
    ;;
  *)
    echo "Unsupported chat channel for cron registration: $CHANNEL_KIND" >&2
    exit 1
    ;;
esac

if [ -z "$DESTINATION" ]; then
  echo "Channel destination is missing for CHAT_CHANNEL=$CHANNEL_KIND" >&2
  exit 1
fi

gateway_ready="false"
for _ in $(seq 1 30); do
  if command -v curl >/dev/null 2>&1 && curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; then
    gateway_ready="true"
    break
  fi
  sleep 1
done

if [ "$gateway_ready" != "true" ]; then
  echo "OpenClaw gateway did not become healthy on port $PORT." >&2
  exit 1
fi

JOBS_JSON="$TMP_DIR/desired-jobs.json"
EXISTING_JSON="$TMP_DIR/existing-jobs.json"

node - "$CRON_TEMPLATE" > "$JOBS_JSON" <<'NODE'
const fs = require("node:fs");

const raw = fs.readFileSync(process.argv[2], "utf8");
const jobs = [];
let inCron = false;
let current = null;

const resolveEnvToken = (value) => {
  const match = value.match(/^\$\{([A-Z_][A-Z0-9_]*)(:-([^}]*))?\}$/);
  if (!match) {
    return value;
  }
  const envName = match[1];
  const fallback = match[3] || "";
  return process.env[envName] || fallback;
};

const unquote = (value) => {
  const trimmed = value.trim();
  if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
    return resolveEnvToken(JSON.parse(trimmed));
  }
  if (trimmed.startsWith("'") && trimmed.endsWith("'")) {
    return resolveEnvToken(trimmed.slice(1, -1));
  }
  return resolveEnvToken(trimmed);
};

for (const line of raw.split(/\r?\n/)) {
  const trimmed = line.trim();
  if (!trimmed || trimmed.startsWith("#")) {
    continue;
  }
  if (/^cron:\s*$/.test(trimmed)) {
    inCron = true;
    continue;
  }
  if (!inCron) {
    continue;
  }
  const jobMatch = line.match(/^  ([A-Za-z0-9_-]+):\s*$/);
  if (jobMatch) {
    current = { key: jobMatch[1] };
    jobs.push(current);
    continue;
  }
  const fieldMatch = line.match(/^    ([A-Za-z0-9_-]+):\s*(.+)\s*$/);
  if (current && fieldMatch) {
    current[fieldMatch[1]] = unquote(fieldMatch[2]);
  }
}

process.stdout.write(JSON.stringify(jobs, null, 2));
NODE

openclaw cron list --all --json > "$EXISTING_JSON"

node - "$JOBS_JSON" "$EXISTING_JSON" "$CHANNEL_KIND" "$DESTINATION" <<'NODE'
const fs = require("node:fs");
const { spawnSync } = require("node:child_process");

const desired = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const existing = JSON.parse(fs.readFileSync(process.argv[3], "utf8"));
const channelKind = process.argv[4];
const destination = process.argv[5];

const existingByName = new Map((existing.jobs || []).map((job) => [job.name, job]));

const run = (args) => {
  const res = spawnSync("openclaw", args, { stdio: "inherit" });
  if (res.status !== 0) {
    process.exit(res.status || 1);
  }
};

for (const job of desired) {
  const name = job.key
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
  const args = existingByName.has(name)
    ? ["cron", "edit", existingByName.get(name).id]
    : ["cron", "add", "--name", name];

  args.push(
    "--session",
    "isolated",
    "--agent",
    String(job.agent || "producer"),
    "--cron",
    String(job.schedule),
    "--tz",
    String(job.timezone || "UTC"),
    "--message",
    String(job.message || ""),
    "--announce",
    "--channel",
    channelKind,
    "--to",
    `channel:${destination}`,
    "--best-effort-deliver",
  );

  run(args);
}
NODE

echo "Registered ChatBizOS cron jobs for $CHANNEL_KIND channel:$DESTINATION"
