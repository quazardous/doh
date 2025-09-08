FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    supervisor \
    sudo \
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000

# Create user matching host UID/GID
RUN groupadd -g ${GID} app \
    && useradd -u ${UID} -g ${GID} -m -s /bin/bash app

# sudo access for app user (dev convenience)
RUN echo 'app ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
RUN echo 'app:docker' | chpasswd

# Supervisor Configuration
COPY ./docker/supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /app

# Create project log directories
RUN mkdir -p /app/var/log/supervisor /app/var/run/supervisor \
    && chown -R app:app /app/var \
    && chmod -R 755 /app/var

# Install Python dependencies
COPY --chown=${UID}:${GID} requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY --chown=${UID}:${GID} . .

# Switch to app user
USER app

EXPOSE 8000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]