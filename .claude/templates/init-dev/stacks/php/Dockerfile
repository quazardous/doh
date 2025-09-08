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
ARG UID=1000
ARG GID=1000

# Configure www-data user with dynamic UID/GID
RUN groupmod -g ${GID} www-data && usermod -u ${UID} -g ${GID} -d /app www-data

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1

# Supervisor Configuration (dev-friendly permissions)
COPY ./docker/supervisord.conf /etc/supervisor/supervisord.conf

# Create project log directories
RUN mkdir -p /app/var/log/supervisor /app/var/run/supervisor \
    && chown -R www-data:www-data /app/var \
    && chmod -R 755 /app/var

# sudo access for www-data (dev convenience)
RUN echo 'www-data ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
RUN echo 'www-data:docker' | chpasswd

# Set working directory
WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install PHP dependencies as www-data
USER www-data
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy application code (switch back to root for COPY)
USER root
COPY . .

# Set permissions for Laravel
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache

# Switch to www-data user for runtime
USER www-data

# Expose port 9000 (PHP-FPM)
EXPOSE 9000

# Start supervisord as app user
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]