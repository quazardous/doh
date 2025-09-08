FROM node:20-alpine

# Install additional packages if needed
RUN apk add --no-cache \
    git \
    curl \
    bash

ARG UID=1000
ARG GID=1000

# Modify existing node user instead of creating new one
RUN deluser --remove-home node \
    && addgroup -g ${GID} nodeuser \
    && adduser -u ${UID} -G nodeuser -s /bin/bash -D nodeuser

WORKDIR /app

# Install dependencies as root, then change ownership
COPY --chown=${UID}:${GID} package*.json ./
RUN npm ci

# Copy source code
COPY --chown=${UID}:${GID} . .

# Switch to non-root user for running the app
USER nodeuser

EXPOSE 3000
CMD ["npm", "start"]