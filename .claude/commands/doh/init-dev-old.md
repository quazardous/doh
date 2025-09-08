---
allowed-tools: Bash, Glob, Grep, LS, Read, Write, Edit, MultiEdit
---

# Initialize Development Stack

Set up a pragmatic, Docker-focused development environment with multi-project support, SSL certificates, and appropriate dev tools based on detected or specified stack. Also capable of analyzing and improving existing Docker setups that don't meet DOH standards.

## Usage
```
/doh:init-dev <natural language stack description>
/doh:init-dev "Node.js API with PostgreSQL and Redis"
/doh:init-dev "PHP Laravel application with MySQL"
/doh:init-dev "Python FastAPI with PostgreSQL"
/doh:init-dev "Full-stack React + Express + PostgreSQL"
```

## Examples
- `/doh:init-dev "Node.js with Express, PostgreSQL, and Redis"`
- `/doh:init-dev "PHP application with MySQL and phpMyAdmin"`
- `/doh:init-dev "Python Django with PostgreSQL and Celery"`
- `/doh:init-dev "Vue.js frontend with FastAPI backend"`

## Core Philosophy

### Docker-Focused & Pragmatic
- **Docker as standard** unless explicitly contraindicated
- **Realistic containers** - avoid over-containerization
- **Multi-project friendly** - `{service}.{project}.local` domains

### Existing Environment Respect & Improvement
- **Analyze first** - detect existing Docker setups that don't meet DOH standards
- **Explain improvements** - clearly show what issues exist and what will be fixed
- **User confirmation** - always ask before modifying existing configurations
- **Safe upgrades** - create backups before applying improvements
- **Flexible options** - improve existing, create alongside, or add components only
- **Zero permission issues** - UID/GID matching
- **Developer-friendly** - one command to start working

### Multi-Project Support
- **Domain pattern**: `{service}.{project}.local`
- **SSL certificates**: Wildcard `*.{project}.local` with mkcert
- **Port isolation**: Only Traefik ports (80/443) exposed
- **Project workspace**: Each project self-contained

## Implementation Steps

### 1. Detect or Parse Stack Requirements

```bash
# Parse natural language input to identify components
STACK_INPUT="$1"

# Default project name from directory
PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')

echo "🔍 Analyzing stack requirements: $STACK_INPUT"
echo "📁 Project name: $PROJECT_NAME"

# Component detection logic
NEEDS_NODE=false
NEEDS_PHP=false  
NEEDS_PYTHON=false
NEEDS_POSTGRES=false
NEEDS_MYSQL=false
NEEDS_REDIS=false
NEEDS_NGINX=false

# Parse input for components
[[ "$STACK_INPUT" =~ (node|express|react|vue|next|nuxt) ]] && NEEDS_NODE=true
[[ "$STACK_INPUT" =~ (php|laravel|symfony|wordpress) ]] && NEEDS_PHP=true
[[ "$STACK_INPUT" =~ (python|django|fastapi|flask) ]] && NEEDS_PYTHON=true
[[ "$STACK_INPUT" =~ (postgres|postgresql) ]] && NEEDS_POSTGRES=true
[[ "$STACK_INPUT" =~ (mysql|mariadb) ]] && NEEDS_MYSQL=true
[[ "$STACK_INPUT" =~ (redis|cache) ]] && NEEDS_REDIS=true
```

### 2. Check Existing Environment & Analyze Docker Standards

```bash
# Check existing Docker setup
DOCKER_ISSUES=()
NEEDS_IMPROVEMENT=false

if [[ -f "docker-compose.yml" ]]; then
    echo "🔍 Analyzing existing docker-compose.yml against DOH standards..."
    
    # Check for common issues
    if grep -q "ports:" docker-compose.yml && ! grep -q "traefik" docker-compose.yml; then
        DOCKER_ISSUES+=("❌ Direct port exposure without Traefik routing")
        NEEDS_IMPROVEMENT=true
    fi
    
    if ! grep -q "user:" docker-compose.yml && ! grep -q "UID" docker-compose.yml; then
        DOCKER_ISSUES+=("❌ No UID/GID matching - potential permission issues")
        NEEDS_IMPROVEMENT=true
    fi
    
    if ! grep -q "traefik" docker-compose.yml && ! grep -q "labels:" docker-compose.yml; then
        DOCKER_ISSUES+=("❌ Missing Traefik routing configuration")
        NEEDS_IMPROVEMENT=true
    fi
    
    if grep -q "localhost" docker-compose.yml; then
        DOCKER_ISSUES+=("⚠️ Localhost references - not multi-project friendly")
        NEEDS_IMPROVEMENT=true
    fi
    
    if [[ ${#DOCKER_ISSUES[@]} -gt 0 ]]; then
        echo ""
        echo "🚨 Docker Setup Issues Detected:"
        for issue in "${DOCKER_ISSUES[@]}"; do
            echo "  $issue"
        done
        echo ""
        echo "💡 Recommended Improvements:"
        echo "  • Add Traefik routing with {service}.${PROJECT_NAME}.local domains"
        echo "  • Implement UID/GID matching for zero permission issues"
        echo "  • Use internal networking instead of direct port exposure"
        echo "  • Add development tools access (adminer, mailhog, etc.)"
        echo ""
        echo "Options:"
        echo "1. ✅ Improve existing setup to DOH standards"
        echo "2. 🔄 Create improved dev.docker-compose.yml alongside existing"
        echo "3. ➕ Add only missing components without changing existing"
        echo "4. ❌ Skip Docker setup improvements"
        echo ""
        echo "👉 Choose option (1-4): "
        # This will be handled by natural language interaction in practice
    else
        echo "✅ Existing Docker setup meets DOH standards"
    fi
fi

if [[ -f "Makefile" ]]; then
    echo "⚠️ Existing Makefile found - will enhance with Docker dev targets"
fi
```

### 3. Handle Existing Docker Setup Improvements

Based on user choice for existing Docker setups:

**Option 1: Improve existing setup to DOH standards**
```bash
if [[ "$USER_CHOICE" == "1" ]]; then
    echo "🔧 Improving existing docker-compose.yml to DOH standards..."
    
    # Backup original
    cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
    echo "📋 Created backup: docker-compose.yml.backup.*"
    
    # Apply improvements
    echo "✨ Applying improvements:"
    echo "  • Adding Traefik routing configuration"
    echo "  • Implementing UID/GID matching"
    echo "  • Converting direct ports to internal networking"
    echo "  • Adding development tools containers"
    echo "  • Configuring multi-project domain pattern"
    
    # [Implementation would modify existing docker-compose.yml]
fi
```

**Option 2: Create improved dev.docker-compose.yml**
```bash
if [[ "$USER_CHOICE" == "2" ]]; then
    echo "📄 Creating dev.docker-compose.yml with DOH standards alongside existing setup"
    echo "🔀 You can use: docker-compose -f dev.docker-compose.yml up"
    # [Generate new file without touching existing]
fi
```

**Option 3: Add only missing components**
```bash
if [[ "$USER_CHOICE" == "3" ]]; then
    echo "➕ Adding only missing development components without modifying existing structure"
    # [Add traefik, dev tools as separate services without changing existing services]
fi
```

### 4. Generate Core Files

**4a. Create docker-compose.env-docker (Template)**
```bash
cat > docker-compose.env-docker << EOF
# Project Configuration
DEV_PROJECT=$PROJECT_NAME
SITE_BASE_DOMAIN=${PROJECT_NAME}.local

# User IDs (auto-detected in Makefile)
#UID=1000
#GID=1000

# External Ports (Traefik)
EXTERNAL_HTTP_PORT=80
EXTERNAL_HTTPS_PORT=443

# Application Environment
APPLICATION_ENV=development

$(if $NEEDS_POSTGRES; then cat << POSTGRES_BLOCK
# PostgreSQL Configuration
POSTGRES_DB=${PROJECT_NAME}_dev
POSTGRES_USER=dev
POSTGRES_PASSWORD=secret
POSTGRES_BLOCK
fi)

$(if $NEEDS_MYSQL; then cat << MYSQL_BLOCK
# MySQL Configuration  
MYSQL_DATABASE=${PROJECT_NAME}_dev
MYSQL_USER=dev
MYSQL_PASSWORD=secret
MYSQL_ROOT_PASSWORD=secret
MYSQL_BLOCK
fi)

$(if $NEEDS_REDIS; then echo "# Redis Configuration"; fi)
EOF
```

**4b. Generate docker-compose.yml with Simplified Traefik Pattern**
```bash
cat > docker-compose.yml << 'EOF'
services:
  traefik:
    image: traefik:v3.1
    command:
      - "--configFile=/etc/traefik/traefik.yml"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/etc/traefik/traefik.yml:ro
      - ./dynamic.yaml:/etc/traefik/dynamic.yaml:ro
      - ./certs:/certs:ro
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080" # dashboard
    networks:
      - default

EOF

# Add application service based on detected stack
if [[ "$NEEDS_NODE" == true ]]; then
cat >> docker-compose.yml << NODE_BLOCK
  app:
    build: 
      context: ./app
      args:
        UID: \${UID:-1000}
        GID: \${GID:-1000}
    volumes:
      - ./app:/usr/src/app
    user: \${UID:-1000}:\${GID:-1000}
    environment:
      - NODE_ENV=development
    labels:
      - "traefik.enable=true"
      - "dev.project=${PROJECT_NAME}"
      - "traefik.http.routers.app.rule=Host(\`app.${PROJECT_NAME}.localhost\`)"
      - "traefik.http.routers.app.entrypoints=websecure"
      - "traefik.http.routers.app.tls=true"
      - "traefik.http.services.app.loadbalancer.server.port=3000"
    networks:
      - default

NODE_BLOCK
fi

if [[ "$NEEDS_PHP" == true ]]; then
cat >> docker-compose.yml << PHP_BLOCK
  app:
    build: 
      context: ./app
      args:
        UID: \${UID:-1000}
        GID: \${GID:-1000}
    volumes:
      - ./app:/var/www/html
    user: \${UID:-1000}:\${GID:-1000}
    labels:
      - "traefik.enable=true"
      - "dev.project=${PROJECT_NAME}"
      - "traefik.http.routers.app.rule=Host(\`app.${PROJECT_NAME}.localhost\`)"
      - "traefik.http.routers.app.entrypoints=websecure"
      - "traefik.http.routers.app.tls=true"
      - "traefik.http.services.app.loadbalancer.server.port=80"
    networks:
      - default

PHP_BLOCK
fi

# Add database services
if [[ "$NEEDS_POSTGRES" == true ]]; then
cat >> docker-compose.yml << POSTGRES_BLOCK
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: \${POSTGRES_DB:-${PROJECT_NAME}_dev}
      POSTGRES_USER: \${POSTGRES_USER:-dev}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD:-secret}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - default

  adminer:
    image: adminer
    depends_on:
      - postgres
    labels:
      - "traefik.enable=true"
      - "dev.project=${PROJECT_NAME}"
      - "traefik.http.routers.adminer.rule=Host(\`adminer.${PROJECT_NAME}.localhost\`)"
      - "traefik.http.routers.adminer.entrypoints=websecure"
      - "traefik.http.routers.adminer.tls=true"
    networks:
      - default

POSTGRES_BLOCK
fi

if [[ "$NEEDS_MYSQL" == true ]]; then
cat >> docker-compose.yml << MYSQL_BLOCK
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: \${MYSQL_DATABASE:-${PROJECT_NAME}_dev}
      MYSQL_USER: \${MYSQL_USER:-dev}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD:-secret}
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD:-secret}
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - default

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    environment:
      - PMA_HOST=mysql
      - PMA_PORT=3306
    depends_on:
      - mysql
    labels:
      - "traefik.enable=true"
      - "dev.project=${PROJECT_NAME}"
      - "traefik.http.routers.phpmyadmin.rule=Host(\`phpmyadmin.${PROJECT_NAME}.localhost\`)"
      - "traefik.http.routers.phpmyadmin.entrypoints=websecure"
      - "traefik.http.routers.phpmyadmin.tls=true"
    networks:
      - default

MYSQL_BLOCK
fi

if [[ "$NEEDS_REDIS" == true ]]; then
cat >> docker-compose.yml << REDIS_BLOCK
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - default

REDIS_BLOCK
fi

# Add common development services
cat >> docker-compose.yml << MAILHOG_BLOCK
  mailhog:
    image: mailhog/mailhog
    labels:
      - "traefik.enable=true"
      - "dev.project=${PROJECT_NAME}"
      - "traefik.http.routers.mailhog.rule=Host(\`mailhog.${PROJECT_NAME}.localhost\`)"
      - "traefik.http.routers.mailhog.entrypoints=websecure"
      - "traefik.http.routers.mailhog.tls=true"
      - "traefik.http.services.mailhog.loadbalancer.server.port=8025"
    networks:
      - default

MAILHOG_BLOCK

# Add volumes and networks
cat >> docker-compose.yml << FOOTER_BLOCK

volumes:$(if [[ "$NEEDS_POSTGRES" == true ]]; then echo "
  postgres_data:"; fi)$(if [[ "$NEEDS_MYSQL" == true ]]; then echo "
  mysql_data:"; fi)$(if [[ "$NEEDS_REDIS" == true ]]; then echo "
  redis_data:"; fi)

networks:
  default:
    driver: bridge
FOOTER_BLOCK
```

**4c. Generate mkcert HTTPS Certificates**
```bash
# Create certs directory
mkdir -p certs

# Generate HTTPS certificates with mkcert
if ! command -v mkcert &> /dev/null; then
    echo "📦 Installing mkcert..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install mkcert
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Install mkcert on Linux
        curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
        chmod +x mkcert-v*-linux-amd64
        sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
    fi
    
    # Install CA
    mkcert -install
    echo "✅ mkcert CA installed"
fi

# Generate localhost certificate
cd certs
mkcert localhost "*.${PROJECT_NAME}.localhost" "${PROJECT_NAME}.localhost"
echo "🔐 Generated HTTPS certificates:"
echo "  • certs/localhost.pem"  
echo "  • certs/localhost-key.pem"
cd ..
```

**4d. Generate Traefik Configuration Files**
```bash
# Generate traefik.yml-docker (template)
cat > traefik.yml-docker << EOF
global:
  sendAnonymousUsage: false

api:
  dashboard: true
  insecure: true   # ⚠️ Dev uniquement

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    watch: true
    exposedByDefault: false
    constraints: "Label(\`dev.project\`, \`${PROJECT_NAME}\`)"  # filtre par projet
  file:
    filename: /etc/traefik/dynamic.yaml
    watch: true

log:
  level: INFO
  filePath: /logs/traefik.log

accessLog:
  filePath: /logs/traefik_access.log

entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"
EOF

# Generate dynamic.yaml-docker (template)
cat > dynamic.yaml-docker << EOF
tls:
  certificates:
    - certFile: /certs/localhost.pem
      keyFile: /certs/localhost-key.pem
EOF

echo "📁 Created Traefik configuration template files"
echo "  • traefik.yml-docker (static config template)"
echo "  • dynamic.yaml-docker (TLS certificates template)"
```

### 5. Create Dockerfile Templates

```bash
# Create app directory structure
mkdir -p app

# Generate appropriate Dockerfile based on stack
if [[ "$NEEDS_NODE" == true ]]; then
cat > app/Dockerfile << NODE_DOCKERFILE
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
    && addgroup -g \${GID} nodeuser \
    && adduser -u \${UID} -G nodeuser -s /bin/bash -D nodeuser

WORKDIR /${PROJECT_NAME}

# Install dependencies as root, then change ownership
COPY --chown=\${UID}:\${GID} package*.json ./
RUN npm ci

# Copy source code
COPY --chown=\${UID}:\${GID} . .

# Switch to non-root user for running the app
USER nodeuser

EXPOSE 3000
CMD ["npm", "start"]
NODE_DOCKERFILE
fi

if [[ "$NEEDS_PHP" == true ]]; then
cat > app/Dockerfile << PHP_DOCKERFILE
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    git \\
    curl \\
    libpng-dev \\
    libonig-dev \\
    libxml2-dev \\
    libzip-dev \\
    zip \\
    unzip \\
    nginx \\
    supervisor \\
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ARG UID=1000
ARG GID=1000

# Modify existing www-data user to match host UID/GID
RUN groupmod -g \${GID} www-data \\
    && usermod -u \${UID} -g \${GID} -d /${PROJECT_NAME} www-data

# Add sudo permissions for development
RUN apt-get update && apt-get install -y sudo \\
    && echo 'www-data ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \\
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /${PROJECT_NAME}

# Copy application
COPY --chown=\${UID}:\${GID} . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Configure PHP-FPM to run as www-data
RUN sed -i 's/user = www-data/user = www-data/' /usr/local/etc/php-fpm.d/www.conf \\
    && sed -i 's/group = www-data/group = www-data/' /usr/local/etc/php-fpm.d/www.conf

EXPOSE 9000
CMD ["php-fpm"]
PHP_DOCKERFILE
fi

if [[ "$NEEDS_PYTHON" == true ]]; then
cat > app/Dockerfile << PYTHON_DOCKERFILE
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    build-essential \\
    curl \\
    git \\
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000

# Create user matching host UID/GID
RUN groupadd -g \${GID} appuser \\
    && useradd -u \${UID} -g \${GID} -m -s /bin/bash appuser

WORKDIR /${PROJECT_NAME}

# Install Python dependencies
COPY --chown=\${UID}:\${GID} requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY --chown=\${UID}:\${GID} . .

# Switch to non-root user
USER appuser

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
PYTHON_DOCKERFILE
fi

echo "📦 Created Dockerfile templates in app/"
```

### 6. Generate Comprehensive Makefile

```bash
# Generate comprehensive Makefile for development
cat > Makefile << 'MAKEFILE_CONTENT'
.PHONY: help
.DEFAULT_GOAL := help

# Auto-detect user IDs to avoid permission issues
export UID := $(shell id -u)
export GID := $(shell id -g)
export PROJECT_NAME := $(shell basename $(PWD) | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')

help: ## Show this help message
	@echo "🔧 Development Environment Commands"
	@echo "=================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# === Environment Management ===

dev: ## Start development environment
	docker compose up -d

stop: ## Stop all containers (preserve data)
	docker compose down

restart: ## Restart all containers (preserve data)
	docker compose down && docker compose up -d

status: ## Show running containers status
	docker compose ps

logs: ## Show container logs
	docker compose logs -f

logs-%: ## Show logs for specific service (e.g. make logs-app)
	docker compose logs -f $*

# === Container Management ===

rebuild: ## 🔄 Rebuild all containers (preserve data)
	docker compose down
	docker compose build --no-cache
	docker compose up -d

rebuild-app: ## 🔄 Rebuild only app container (preserve data)
	docker compose stop app
	docker compose build --no-cache app
	docker compose up -d app

rebuild-%: ## 🔄 Rebuild specific container (e.g. make rebuild-nginx)
	docker compose stop $*
	docker compose build --no-cache $*
	docker compose up -d $*

# === Shell Access ===

shell: ## Access app container shell
	docker compose exec app sh

shell-%: ## Access specific container shell (e.g. make shell-mysql)
	docker compose exec $* sh

# === Database Management ===

clean-data: ## 🔥 DANGER: Reset all database data
	@echo "⚠️  This will delete ALL database data!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	docker compose down
	sudo rm -rf docker-dev/data/*/
	docker compose up -d
	@echo "✅ Database data reset complete"

backup-data: ## Backup database data
	@mkdir -p backups
	@tar -czf backups/db-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz docker-dev/data/ 2>/dev/null || echo "No data to backup"
	@echo "✅ Database backup created"

# === Setup & Validation ===

docker-env: ## Copy all *-docker template files to working files
	@echo "📋 Setting up Docker environment files from templates..."
	@for file in *-docker; do \
		if [ -f "$$file" ]; then \
			target=$${file%-docker}; \
			if [ ! -f "$$target" ]; then \
				cp "$$file" "$$target"; \
				echo "✅ Created $$target from $$file"; \
			else \
				echo "⚠️ $$target already exists (skipped)"; \
			fi; \
		fi; \
	done
	@echo "✅ Docker environment setup complete"

setup: docker-env ssl-setup ## Initial project setup
	@echo "✅ Project setup complete"

ssl-setup: ## Generate SSL certificates
	@echo "🔒 Setting up SSL certificates..."
	@command -v mkcert >/dev/null || (echo "❌ mkcert required" && exit 1)
	@mkcert -install
	@mkdir -p docker-dev/certs
	@mkcert -cert-file docker-dev/certs/localhost.pem -key-file docker-dev/certs/localhost-key.pem "*.$(PROJECT_NAME).localhost"
	@echo "✅ SSL certificates generated"

hello-world: ## 🌍 Validate entire stack is working
	@echo "🌍 Hello World Stack Validation"
	@echo "==============================="
	@echo ""
	@echo "📋 Service Status:"
	@docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" || echo "❌ Docker Compose not running"
	@echo ""
	@echo "🔗 Connectivity Tests:"
	@echo "• Traefik Dashboard: http://localhost:8080"
	@curl -s -o /dev/null -w "• App HTTPS: %{http_code} - https://app.$(PROJECT_NAME).localhost\n" -k https://app.$(PROJECT_NAME).localhost 2>/dev/null || echo "• App HTTPS: ❌ Not responding"
	@echo ""
	@echo "📁 Data Persistence:"
	@ls -la docker-dev/data/ 2>/dev/null | head -5 || echo "• No persistent data found"
	@echo ""
	@echo "🎉 Stack validation complete!"
	@echo ""
	@echo "🚀 Access URLs:"
	@echo "   → https://app.$(PROJECT_NAME).localhost"

# === Maintenance ===

clean: ## Clean containers (preserve data)
	docker compose down -v
	docker system prune -f

update: ## Update container images
	docker compose pull
	$(MAKE) rebuild

MAKEFILE_CONTENT
```

### 7. Generate Install Dependencies Script

```bash
# Create scripts directory in docker-dev
mkdir -p docker-dev/scripts

# Generate comprehensive dependency installer
cat > docker-dev/scripts/install-deps.sh << 'INSTALL_SCRIPT'
#!/bin/bash
set -e

echo "📦 Installing Docker Development Dependencies"
echo "=============================================="

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
    OS="windows"
fi

echo "🔍 Detected OS: $OS"
echo ""

# Install Docker
install_docker() {
    if command -v docker >/dev/null; then
        echo "✅ Docker already installed"
        return
    fi
    
    echo "📦 Installing Docker..."
    case $OS in
        "macos")
            if command -v brew >/dev/null; then
                brew install --cask docker
            else
                echo "❌ Homebrew required on macOS. Install from: https://brew.sh"
                exit 1
            fi
            ;;
        "linux")
            # Install Docker on Ubuntu/Debian
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker $USER
            rm get-docker.sh
            echo "⚠️  Please logout and login again for Docker group to take effect"
            ;;
        "windows")
            echo "❌ Please install Docker Desktop manually from: https://docker.com/products/docker-desktop"
            exit 1
            ;;
        *)
            echo "❌ Unsupported OS: $OSTYPE"
            exit 1
            ;;
    esac
}

# Install mkcert  
install_mkcert() {
    if command -v mkcert >/dev/null; then
        echo "✅ mkcert already installed"
        return
    fi
    
    echo "📦 Installing mkcert..."
    case $OS in
        "macos")
            if command -v brew >/dev/null; then
                brew install mkcert
            else
                echo "❌ Homebrew required. Install from: https://brew.sh"
                exit 1
            fi
            ;;
        "linux")
            if command -v apt >/dev/null; then
                sudo apt update
                sudo apt install -y libnss3-tools
                curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
                chmod +x mkcert-v*-linux-amd64
                sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
            elif command -v yum >/dev/null; then
                sudo yum install -y nss-tools
                curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" 
                chmod +x mkcert-v*-linux-amd64
                sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
            else
                echo "❌ Package manager not supported. Install mkcert manually"
                exit 1
            fi
            ;;
        "windows")
            echo "❌ Please install mkcert manually on Windows"
            echo "   Download from: https://github.com/FiloSottile/mkcert/releases"
            exit 1
            ;;
    esac
}

# Install other tools
install_other_tools() {
    # curl is usually pre-installed, but check anyway
    if ! command -v curl >/dev/null; then
        echo "📦 Installing curl..."
        case $OS in
            "macos")
                echo "✅ curl should be pre-installed on macOS"
                ;;
            "linux")
                if command -v apt >/dev/null; then
                    sudo apt update && sudo apt install -y curl
                elif command -v yum >/dev/null; then
                    sudo yum install -y curl
                fi
                ;;
        esac
    else
        echo "✅ curl already installed"
    fi
    
    # make is usually pre-installed
    if ! command -v make >/dev/null; then
        echo "📦 Installing make..."
        case $OS in
            "macos")
                xcode-select --install
                ;;
            "linux") 
                if command -v apt >/dev/null; then
                    sudo apt update && sudo apt install -y build-essential
                elif command -v yum >/dev/null; then
                    sudo yum groupinstall -y "Development Tools"
                fi
                ;;
        esac
    else
        echo "✅ make already installed"
    fi
}

# Main installation
main() {
    install_docker
    install_mkcert
    install_other_tools
    
    echo ""
    echo "🎉 Installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. make setup    # Setup SSL certificates"  
    echo "2. make dev      # Start development environment"
    echo "3. make hello-world  # Validate everything works"
}

main
INSTALL_SCRIPT

chmod +x docker-dev/scripts/install-deps.sh
echo "📋 Created dependency installation script: docker-dev/scripts/install-deps.sh"

ssl-setup: ## Generate SSL certificates for local development
	@echo "🔒 Setting up SSL certificates..."
	@mkcert -install
	@mkdir -p certs
	@mkcert -cert-file certs/cert.pem -key-file certs/key.pem "*.$(PROJECT_NAME).local"
	@echo "✅ SSL certificates generated for *.$(PROJECT_NAME).local"

dev-setup: docker-env ssl-setup ## Full development environment setup
	@cp docker-compose.env .env 2>/dev/null || echo "⚠️ .env already exists"
	@echo "✅ Development environment ready"

dev: ## Start development environment
	@echo "🚀 Starting development environment for $(PROJECT_NAME)..."
	@echo "  📱 App:     https://app.$(PROJECT_NAME).local"
MAKEFILE_DEV

# Add service URLs based on stack
[[ "$NEEDS_POSTGRES" == true ]] && echo '@echo "  🗄️ DB:      https://adminer.$(PROJECT_NAME).local"' >> Makefile
[[ "$NEEDS_MYSQL" == true ]] && echo '@echo "  🗄️ DB:      https://phpmyadmin.$(PROJECT_NAME).local"' >> Makefile

cat >> Makefile << 'MAKEFILE_END'
	@echo "  📧 Mail:    https://mailhog.$(PROJECT_NAME).local"
	@echo ""
	@docker-compose up -d
	@echo "✅ Development environment running"

logs: ## View application logs
	@docker-compose logs -f app

shell: ## Enter application container
	@docker-compose exec app /bin/sh

test: ## Run tests
	@docker-compose exec app npm test

stop: ## Stop development environment
	@docker-compose down

clean: ## Stop and clean everything
	@docker-compose down -v --remove-orphans
	@docker system prune -f

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
MAKEFILE_END
```

### 6. Create INSTADEV.md

```bash
cat > INSTADEV.md << EOF
# 🚀 INSTADEV - Start coding in 5 minutes

## Prerequisites
- Docker Desktop installed
- mkcert (auto-installed with \`make install\`)
- 8GB RAM minimum

## Quick Start
\`\`\`bash
# One command setup and start
make dev-setup && make dev

# You're done! Services running at:
# 📱 https://app.$PROJECT_NAME.local
# 🗄️ https://adminer.$PROJECT_NAME.local  
# 📧 https://mailhog.$PROJECT_NAME.local
\`\`\`

## Hello World Test
\`\`\`bash
# Test HTTP endpoint
curl -k https://app.$PROJECT_NAME.local/hello

# Test CLI command  
make shell
npm run cli  # or python cli.py, php artisan hello, etc.
\`\`\`

## Common Tasks
\`\`\`bash
make dev        # Start everything
make logs       # View logs
make shell      # Enter container
make test       # Run tests
make stop       # Stop everything
make clean      # Nuclear reset
\`\`\`

## Troubleshooting
**Port conflicts?**
\`\`\`bash
make stop && make clean && make dev
\`\`\`

**SSL issues?**
\`\`\`bash
make ssl-setup
\`\`\`

## Stack Information
**Technology Stack:** $STACK_INPUT
**Project Name:** $PROJECT_NAME
**Generated:** $(date)

## Need Help?
- Check logs: \`make logs\`
- Reset everything: \`make clean && make dev\`
- Container shell: \`make shell\`
EOF
```

### 8. Display Setup Summary

```bash
echo ""
echo "✅ Docker Development Stack Ready!"
echo "=================================="
echo ""
echo "🔐 **HTTPS Domains Generated:**"
echo "  • https://app.${PROJECT_NAME}.localhost (Application)"
if [[ "$NEEDS_POSTGRES" == true ]]; then
    echo "  • https://adminer.${PROJECT_NAME}.localhost (Database Admin)"
fi
if [[ "$NEEDS_MYSQL" == true ]]; then
    echo "  • https://phpmyadmin.${PROJECT_NAME}.localhost (MySQL Admin)"
fi
echo "  • https://mailhog.${PROJECT_NAME}.localhost (Email Testing)"
echo "  • http://localhost:8080 (Traefik Dashboard)"
echo ""
echo "🚀 **Quick Start:**"
echo "  1. Start all services: docker compose up -d"
echo "  2. View logs: docker compose logs -f"
echo "  3. Stop all services: docker compose down"
echo ""
echo "📁 **Files Created:**"
echo "  • docker-compose.yml - Docker services"
echo "  • traefik.yml-docker - Traefik configuration template"
echo "  • dynamic.yaml-docker - TLS certificates config template"
echo "  • docker-dev/certs/ - mkcert HTTPS certificates"
echo "  • docker-dev/scripts/install-deps.sh - Dependency installer"
echo "  • docker-compose.env-docker - Environment variables template (versioned)"
echo "  • Makefile - Development commands"
echo "  • INSTADEV.md - Quick developer guide"
echo ""
echo "💡 **Next Steps:**"
echo "  1. Setup environment files: make docker-env && cp docker-compose.env .env"
echo "  2. Create your app directory: mkdir -p app/"
echo "  3. Add your application code to app/"
echo "  4. Run: docker compose up -d"
echo ""
```

### 9. Generate Install Scripts

```bash
# Create platform-specific install scripts
cat > scripts/install-deps.sh << 'INSTALL_SCRIPT'
#!/bin/bash
set -e

echo "🔧 Installing development dependencies..."

# Detect platform
if command -v brew >/dev/null 2>&1; then
    # macOS with Homebrew
    brew install mkcert docker-compose
elif command -v apt >/dev/null 2>&1; then
    # Ubuntu/Debian
    sudo apt update
    sudo apt install -y mkcert docker-compose
elif command -v yum >/dev/null 2>&1; then
    # CentOS/RHEL
    sudo yum install -y mkcert docker-compose
else
    echo "⚠️ Please install mkcert and docker-compose manually"
fi

echo "✅ Dependencies installed"
INSTALL_SCRIPT

chmod +x scripts/install-deps.sh
```

### 8. Create Hello World Implementation

```bash
# Generate Hello World based on detected stack
if [[ "$NEEDS_NODE" == true ]]; then
    # Create basic Node.js Hello World
    mkdir -p src
    
    cat > src/app.js << 'NODE_HELLO'
const express = require('express');
const app = express();

// HTTP Hello World
app.get('/hello', (req, res) => {
  res.json({ 
    message: 'Hello World',
    timestamp: new Date().toISOString(),
    project: process.env.PROJECT_NAME || 'dev'
  });
});

app.get('/', (req, res) => {
  res.redirect('/hello');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server running on port ${PORT}`);
});
NODE_HELLO

    # CLI Hello World
    cat > src/cli.js << 'NODE_CLI'
#!/usr/bin/env node
console.log('Hello World from CLI');
console.log('Project:', process.env.PROJECT_NAME || 'dev');
console.log('Timestamp:', new Date().toISOString());
NODE_CLI

    chmod +x src/cli.js
    
    # Package.json if not exists
    if [[ ! -f "package.json" ]]; then
        cat > package.json << 'PACKAGE_JSON'
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "scripts": {
    "start": "node src/app.js",
    "cli": "node src/cli.js",
    "test": "echo 'Tests: OK'"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
PACKAGE_JSON
    fi
fi

# Similar implementations for PHP, Python, etc.
```

### 9. Present Setup Summary

```bash
echo ""
echo "✅ Development Stack Initialized Successfully"
echo "=============================================="
echo ""
echo "**📋 Stack:** $STACK_INPUT"
echo "**🏷️ Project:** $PROJECT_NAME"
echo "**🌐 Domain Pattern:** *.${PROJECT_NAME}.local"
echo ""
echo "**📁 Generated Files:**"
echo "• docker-compose.yml - Docker services configuration"
echo "• Dockerfile - Application container"
echo "• Makefile - Development commands"
echo "• INSTADEV.md - Quick start guide"
echo "• docker-compose.env-docker - Environment variables template (versioned)"
echo "• scripts/install-deps.sh - Dependency installer"
echo ""
echo "**🌐 Service URLs (after 'make dev'):**"
echo "• 📱 App: https://app.${PROJECT_NAME}.local"
[[ "$NEEDS_POSTGRES" == true ]] && echo "• 🗄️ DB: https://adminer.${PROJECT_NAME}.local"
[[ "$NEEDS_MYSQL" == true ]] && echo "• 🗄️ DB: https://phpmyadmin.${PROJECT_NAME}.local"
echo "• 📧 Mail: https://mailhog.${PROJECT_NAME}.local"
echo ""
echo "**🚀 Next Steps:**"
echo "1. Review generated files"
echo "2. Run: make dev-setup && make dev"
echo "3. Open: https://app.${PROJECT_NAME}.local"
echo "4. Test Hello World endpoints"
echo ""
echo "**⚡ Quick Start:**"
echo "make dev-setup && make dev"
```

## Integration with Split-S00

The Split-S00 will invoke this command after detecting stack requirements:

```bash
# In Split-S00 implementation
DETECTED_STACK="Node.js API with PostgreSQL and Redis for tennis club management"
/doh:init-dev "$DETECTED_STACK"
```

## Key Features

### Zero Configuration Philosophy
- **One command setup**: `make dev-setup && make dev`
- **Auto-detection**: User IDs, project name, stack components
- **Sensible defaults**: Production-ready configurations
- **Multi-platform**: Works on macOS, Linux, Windows (WSL)

### Security & Permissions
- **UID/GID matching**: No permission issues
- **SSL everywhere**: mkcert for local HTTPS
- **Isolated networks**: Docker networks for security
- **Configurable ports**: Via environment variables

### Developer Experience
- **Fast onboarding**: 5-minute setup for new developers
- **Clear documentation**: INSTADEV.md with examples
- **Helpful commands**: Makefile with common tasks
- **Troubleshooting**: Clear error messages and recovery

### Multi-Project Support
- **Domain isolation**: `{service}.{project}.local` pattern
- **No conflicts**: Each project has its own namespace
- **Shared Traefik**: Efficient resource usage
- **SSL management**: Wildcard certificates per project

This command becomes the foundation for all DOH development environments!