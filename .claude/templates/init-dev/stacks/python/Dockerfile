FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    supervisor \
    sudo \
    && rm -rf /var/lib/apt/lists/*

ARG UID
ARG GID

# Create user matching host UID/GID (standard name: appuser)
RUN groupadd -g ${GID} appuser \
    && useradd -u ${UID} -g ${GID} -m -s /bin/bash appuser

# sudo access for appuser (dev convenience)
RUN echo 'appuser ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
RUN echo 'appuser:docker' | chpasswd

# @AI-Kitchen: SKIP - Do NOT copy supervisord.conf during build
# Supervisor config is mounted at runtime via docker-compose volumes
# This allows dynamic process management without rebuilding containers
# Config location: /app/docker/app/supervisor/supervisord.conf (via app mount)

WORKDIR /app

# Create project log directories
RUN mkdir -p /app/var/log/supervisor /app/var/run/supervisor \
    && chown -R appuser:appuser /app/var \
    && chmod -R 755 /app/var

# @AI-Kitchen: SKIP - Do NOT copy requirements.txt during build
# Python dependencies are installed post-build via make dev-setup
# This allows dynamic dependency management without rebuilding containers
# RUN pip install commands will be executed inside running container

# @AI-Kitchen: SKIP - Do NOT copy application code during build
# Application code is mounted at runtime via docker-compose volumes
# This allows instant code changes without rebuilding containers
# Volume mount: .:/app (defined in docker-compose.yml)

# Switch to appuser
USER appuser

EXPOSE 8000
# Start supervisord to manage processes
# @AI-Kitchen: SUBSTITUTE withe actual supervisord.conf path
CMD ["/usr/bin/supervisord", "-c", "/app/{{CONTAINER_DIR}}/app/supervisor/supervisord.conf"]