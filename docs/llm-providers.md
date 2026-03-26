# LLM Providers

## OpenAI Setup

### API Key
- Create an API key in the OpenAI dashboard.
- Add it to `.env` as `OPENAI_API_KEY`.
- Set `LLM_PROVIDER=openai`.

### OAuth
Some OpenClaw deployments may support account-based auth flows. For this repository, the default setup assumes API-key based configuration because it is simpler for self-hosted deployment.

### Cost Notes
OpenAI costs depend on model choice and usage volume. Expect higher costs if the team performs frequent research or long multi-agent sessions.

## Anthropic Setup

- Create an Anthropic API key.
- Add it to `.env` as `ANTHROPIC_API_KEY`.
- Set `LLM_PROVIDER=anthropic`.

Anthropic may be a good fit if you prefer its model behavior or already use its API elsewhere.

## Local LLM Setup (Ollama)

- Run a local model server such as Ollama.
- Confirm the endpoint is reachable, for example `http://localhost:11434`.
- Set `LLM_PROVIDER=local`.
- Set `LOCAL_LLM_ENDPOINT` to the correct URL.

Be aware that local models may vary significantly in quality and response reliability.

## Switching Providers

To switch providers:
1. Update `LLM_PROVIDER` in `.env`.
2. Ensure the matching credentials are set.
3. Restart the container.

## Cost Estimation by Provider

- **OpenAI**: usually strong quality, variable API cost
- **Anthropic**: similar usage pattern, cost depends on model and prompt length
- **Local**: low marginal token cost after setup, but quality and maintenance tradeoffs are higher

For new users, start with the provider you already understand operationally.
