FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ARG UID=1000
ARG GID=1000

# Modify existing www-data user to match host UID/GID
RUN groupmod -g ${GID} www-data \
    && usermod -u ${UID} -g ${GID} -d /app www-data

# Add sudo permissions for development
RUN apt-get update && apt-get install -y sudo \
    && echo 'www-data ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy application
COPY --chown=${UID}:${GID} . .

# Install PHP dependencies if composer.json exists
RUN if [ -f composer.json ]; then composer install --no-dev --optimize-autoloader; fi

# Configure PHP-FPM
RUN sed -i 's/user = www-data/user = www-data/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/group = www-data/group = www-data/' /usr/local/etc/php-fpm.d/www.conf

EXPOSE 9000
CMD ["php-fpm"]