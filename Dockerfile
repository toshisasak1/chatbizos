FROM node:22-slim

ENV DEBIAN_FRONTEND=noninteractive \
    OPENCLAW_HOME=/opt/chatbizos \
    WORKSPACE_DIR=/opt/chatbizos/workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends bash ca-certificates curl git jq procps \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw

WORKDIR /opt/chatbizos

COPY agents/ ./agents/
COPY config/ ./config/
COPY workspace-template/ ./workspace-template/
COPY setup/ ./setup/
COPY .env.example ./

RUN chmod +x setup/*.sh

EXPOSE 18789

ENTRYPOINT ["/opt/chatbizos/setup/entrypoint.sh"]
