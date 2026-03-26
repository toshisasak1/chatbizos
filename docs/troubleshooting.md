# Troubleshooting

## Gateway Won't Start

Check:
- Docker build logs
- whether port `18789` is already in use
- whether your generated config is valid
- whether `openclaw` was installed correctly in the image

## Discord Bot Not Responding

Check:
- `DISCORD_BOT_TOKEN`
- `DISCORD_GUILD_ID`
- `DISCORD_CHANNEL_ID`
- bot permissions in the server and channel
- whether `CHAT_CHANNEL=discord`

## Slack Bot Not Responding

Check:
- `SLACK_BOT_TOKEN`
- `SLACK_APP_TOKEN`
- `SLACK_CHANNEL_ID`
- whether the app is installed in the workspace
- whether `CHAT_CHANNEL=slack`

## LLM API Errors

Check:
- the correct provider is selected
- the matching API key is present
- the key is still valid
- your network allows outbound API calls

## Agent Not Producing Output

Check:
- whether the workspace files exist
- whether the relevant `SOUL.md` was deployed
- whether Producer is delegating clear tasks
- whether the request requires human confirmation before progress can continue

## Workspace Files Not Updating

Check:
- that `./workspace` is mounted into the container
- file permissions on the host system
- whether the container started with the expected `WORKSPACE_DIR`
- whether the agent is writing to a different workspace path than expected
