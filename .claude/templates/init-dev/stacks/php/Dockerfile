# Multi-stage pour cherry-pick tools si nécessaire
FROM composer:2 AS composer-tools
{{CONDITIONAL_NODE_STAGE}}

# Image finale PHP-FPM (standard pour tous projets PHP)
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    supervisor \
    sudo \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# PHP Configuration
COPY ./docker/php/98-misc.ini /usr/local/etc/php/conf.d/
COPY ./docker/php/99-php-limits.ini /usr/local/etc/php/conf.d/

# UID/GID Arguments (from docker-compose.yml)
ARG UID
ARG GID

# Configure www-data user with dynamic UID/GID
RUN groupmod -g ${GID} www-data && usermod -u ${UID} -g ${GID} -d /app www-data

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1

# @AI-Kitchen: SKIP - Do NOT copy supervisord.conf during build
# Supervisor config is mounted at runtime via docker-compose volumes
# This allows dynamic process management without rebuilding containers
# Config location: /app/docker/app/supervisor/supervisord.conf (via app mount)

# Create project log directories
RUN mkdir -p /app/var/log/supervisor /app/var/run/supervisor \
    && chown -R www-data:www-data /app/var \
    && chmod -R 755 /app/var

# sudo access for www-data (dev convenience)
RUN echo 'www-data ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
RUN echo 'www-data:docker' | chpasswd

# Set working directory
WORKDIR /app

# @AI-Kitchen: SKIP - Do NOT copy composer.json during build
# PHP dependencies are installed post-build via make dev-setup
# This allows dynamic dependency management without rebuilding containers
# composer install commands will be executed inside running container

# @AI-Kitchen: SKIP - Do NOT copy application code during build
# Application code is mounted at runtime via docker-compose volumes
# This allows instant code changes without rebuilding containers
# Volume mount: .:/app (defined in docker-compose.yml)

# @AI-Kitchen: SKIP - Application permissions handled at runtime
# Volume mounted application will have proper permissions via UID/GID mapping
# Laravel-specific directories created and configured post-build

# Switch to www-data user for runtime
USER www-data

# Expose port 9000 (PHP-FPM)
EXPOSE 9000

# Start supervisord with mounted config
CMD ["/usr/bin/supervisord", "-c", "/app/docker/app/supervisor/supervisord.conf"]