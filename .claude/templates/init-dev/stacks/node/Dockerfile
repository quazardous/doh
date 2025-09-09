FROM node:20-alpine

# Install additional packages if needed
RUN apk add --no-cache \
    git \
    curl \
    bash

ARG UID
ARG GID

# Modify existing node user instead of creating new one
RUN deluser --remove-home node \
    && addgroup -g ${GID} nodeuser \
    && adduser -u ${UID} -G nodeuser -s /bin/bash -D nodeuser

WORKDIR /app

# @AI-Kitchen: SKIP - Do NOT copy package*.json during build
# Node.js dependencies are installed post-build via make dev-setup
# This allows dynamic dependency management without rebuilding containers
# npm install commands will be executed inside running container

# @AI-Kitchen: SKIP - Do NOT copy application code during build
# Application code is mounted at runtime via docker-compose volumes
# This allows instant code changes without rebuilding containers
# Volume mount: .:/app (defined in docker-compose.yml)

# Switch to non-root user for running the app
USER nodeuser

EXPOSE 3000
CMD ["npm", "start"]