# Docker Development Environment - DOH Patterns

## Host Prerequisites

**Required on host machine:**
- **Docker** (Docker Desktop or Docker Engine) - All application dependencies run in containers
- **Docker Compose** v2+ (usually included with Docker Desktop)
  - Uses `docker compose` command (not old `docker-compose`)
  - Version check: `docker compose version`
- **mkcert** - For local SSL certificates generation
  - Installation check: `mkcert -version`
  - First time setup: `mkcert -install`
- **make** - For running Makefile commands (optional but recommended)
  - Can manually run docker commands if make unavailable
- **curl** - For downloading dependencies (usually pre-installed)
- **git** - For version control

**System requirements:**
- **Linux/macOS**: Native Docker support
- **Windows**: 
  - Windows 10 version 2004+ or Windows 11
  - WSL2 required (not WSL1)
  - Docker Desktop with WSL2 backend
  - Work inside WSL2 terminal, not PowerShell/CMD
  - File performance best when project files are in WSL2 filesystem (~/projects)
- **File permissions:** UID/GID must be exported for proper volume permissions
  - Linux/macOS/WSL2: `export UID && export GID=$(id -g)` before Docker commands

**NOT required on host (handled by Docker containers):**
- ❌ Python, pip, virtualenv - Runs in Python container
- ❌ Node.js, npm, yarn - Runs in Node container or app container
- ❌ PHP, Composer - Runs in PHP container
- ❌ Database clients - Runs in database containers
- ❌ Redis, Memcached - Runs in service containers
- ❌ Any language-specific tools - All in containers

## Docker Configuration Rules

### Volume Mount Patterns
**@AI-Kitchen: COPY vs VOLUME rules**

**Always VOLUME mount (never COPY):**
- Application source code: `./:/app`
- Development configuration files: `./docker/app/supervisord.conf:/etc/supervisor/supervisord.conf:ro`
- Data persistence: `./var/data/mariadb:/var/lib/mysql`
- Log directories: `./var/log/traefik:/var/log/traefik`

**Always COPY (never VOLUME):**
- System daemon configs: `/etc/mysql/`, `/etc/postgresql/`, `/etc/nginx/`
- Container-level configurations that need to be baked into image

**Example:**
```dockerfile
# ✅ Correct - System daemon config
COPY ./docker/mysql-custom.cnf /etc/mysql/conf.d/

# ❌ Wrong - Application code should be volume mounted, not copied
COPY ./src /app/src
```

### Multi-stage Dockerfile Strategy
**@AI-Kitchen: CONDITIONAL stages based on detected technologies**

#### Tool Detection & Selection Pattern
```dockerfile
# =================================
# CONDITIONAL STAGES - AI DETECTION
# =================================
# 1. AI détecte la stack (Django + Vue par analyse de requête)
# 2. AI génère seulement les stages nécessaires:

FROM node:20.11.0-bookworm AS node-tools  # SEULEMENT si frontend détecté
WORKDIR /tmp
# Installation outils Node.js : npm, yarn, pnpm selon package.json analysis

FROM composer:2.7 AS composer-tools       # SEULEMENT si PHP détecté
WORKDIR /tmp
# Installation Composer tools

# =================================
# MAIN STAGE - Écosystème choisi
# =================================
FROM python:3.12-slim AS python-base      # Choix selon AI stack detection
WORKDIR /app

# Cherry-pick seulement les outils détectés
COPY --from=node-tools /usr/local/bin/node /usr/local/bin/node
COPY --from=node-tools /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-tools /usr/local/bin/npm /usr/local/bin/npm
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# 🚨 PAS DE COMPOSER - car Python n'utilise pas Composer (outil PHP)
# Dependencies Python installées via pip APRÈS build (post-build pattern)

# Système dependencies pour Python
RUN apt-get update && apt-get install -y build-essential git python3-dev libpq-dev
```

#### Cherry-Pick Rules
- **Conditional Stages:** Only create stages for detected technologies
- **Tool Isolation:** Each tool in its own stage to avoid conflicts
- **Selective Copy:** `COPY --from=stage` only needed binaries/libraries
- **Image Optimization:** Avoid tool bloat in final image

### Container Process Management
**@AI-Kitchen: Main container MUST have daemon process**

**Required:** Main app container must run a persistent process:
```dockerfile
# ✅ Option 1: supervisord (recommended for multiple processes)
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# ✅ Option 2: Single long-running process
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# ✅ Option 3: Sleep infinity (for pure development)
CMD ["sleep", "infinity"]

# ❌ Wrong: Container will exit immediately
CMD ["echo", "Hello world"]
```

### Network & Service Discovery
**@AI-Kitchen: Project isolation patterns**

```yaml
# docker-compose.yml
networks:
  default:
    name: "{{PROJECT_NAME}}-network"

services:
  app:
    labels:
      - "dev.project={{PROJECT_NAME}}"
    networks:
      - default

# Traefik constraint for project isolation
providers:
  docker:
    constraints: "Label(`dev.project`, `{{PROJECT_NAME}}`)"
```

### UID/GID Permission Handling
**@AI-Kitchen: Critical permission setup**

```dockerfile
# Dockerfile
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} app && useradd -u ${UID} -g ${GID} -m app
USER app
```

```yaml
# docker-compose.yml
services:
  app:
    build:
      args:
        UID: ${UID:-1000}
        GID: ${GID:-1000}
```

```bash
# Before any docker command
export UID && export GID=$(id -g) && docker compose build
```

## Directory Structure Standards

### Standard Project Layout
```
docker/
├── app/
│   ├── Dockerfile              # Multi-stage with framework dependencies
│   └── supervisord.conf        # Process management (web + workers)
├── {database}/                 # mariadb/, postgres/, etc.
│   └── conf.d/                 # Database-specific configurations
└── traefik/
    ├── certs/                  # SSL certificates (mkcert generated)
    └── etc/
        ├── traefik.yaml        # Main Traefik configuration
        └── dynamic.yaml        # SSL certificate mappings

var/
├── data/
│   └── {database}/            # Database data persistence
├── log/
│   ├── app/                   # Application logs
│   ├── {database}/            # Database logs
│   └── traefik/               # Traefik access/error logs
└── tmp/                       # Temporary files
```

### Traefik SSL Configuration
**@AI-Kitchen: mkcert certificate setup**

```yaml
# traefik/etc/dynamic.yaml
tls:
  certificates:
    - certFile: "/etc/ssl/certs/{{PROJECT_NAME}}.localhost.pem"
      keyFile: "/etc/ssl/certs/{{PROJECT_NAME}}.localhost-key.pem"
    - certFile: "/etc/ssl/certs/_wildcard.{{PROJECT_NAME}}.localhost.pem"
      keyFile: "/etc/ssl/certs/_wildcard.{{PROJECT_NAME}}.localhost-key.pem"
```

```bash
# Certificate generation
mkcert "{{PROJECT_NAME}}.localhost" "*.{{PROJECT_NAME}}.localhost"
```

### Port Configuration Standards
```bash
# docker-compose.env-docker
EXTERNAL_HTTP_PORT=8000         # Host port for HTTP (redirects to HTTPS)
EXTERNAL_HTTPS_PORT=8443        # Host port for HTTPS
EXTERNAL_TRAEFIK_PORT=8081      # Traefik dashboard port
```

## Database Auto-Provisioning
**@AI-Kitchen: No manual scripts needed**

### MySQL/MariaDB
Docker images handle database and user creation automatically:
```yaml
environment:
  MYSQL_DATABASE: ${MYSQL_DATABASE:-{{PROJECT_NAME}}}
  MYSQL_USER: ${MYSQL_USER:-{{PROJECT_NAME}}}
  MYSQL_PASSWORD: ${MYSQL_PASSWORD:-{{PROJECT_NAME}}}
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-{{PROJECT_NAME}}}
```

**No initialization scripts required** - Docker handles:
- Database creation on first run
- User creation with full privileges on the database
- Password setup
- Application can connect immediately

### PostgreSQL
```yaml
environment:
  POSTGRES_DB: ${POSTGRES_DB:-{{PROJECT_NAME}}}
  POSTGRES_USER: ${POSTGRES_USER:-{{PROJECT_NAME}}}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-{{PROJECT_NAME}}}
```

## Common Docker Commands

### Development Workflow
```bash
# Setup environment (copy -docker files to local)
make env-config

# Build containers with proper permissions
export UID && export GID=$(id -g) && docker compose build

# Start development environment
docker compose up -d

# View logs
docker compose logs -f app

# Execute commands in containers
docker compose exec app bash
docker compose exec app python manage.py migrate

# Stop environment
docker compose down

# Full cleanup (containers + volumes + images)
docker compose down -v --rmi all
```

### Debugging Commands
```bash
# Test container basic access
docker compose run --rm --entrypoint '' app ls -la

# Check container process
docker compose exec app ps aux

# Inspect volumes
docker compose exec app df -h
docker volume ls

# Network inspection
docker network ls
docker network inspect {{PROJECT_NAME}}-network
```

## Directory Organization & Project Structure

### Container-Organized Structure with docker-compose at Root

**🚨 IMPÉRATIF**: Docker Compose files at project root + container-organized structure:

- **docker-compose.yml**: ALWAYS at project root (context: . works correctly)
- **docker-compose.env**: ALWAYS at project root (same level as docker-compose.yml)
- User can specify container directory: "in ./docker" → creates structure in `./docker/app/`, `./docker/traefik/`
- Default: `./docker` (DOH standard) → creates structure in `./docker/app/`, `./docker/traefik/`
- **MANDATORY structure**: Each container gets its own sub-folder with proper build context

### Generated Structure Example
```
project-root/                   # Racine du projet
├── docker-compose.yml          # 🚨 OBLIGATOIRE À LA RACINE - Main orchestration  
├── docker-compose.env          # 🚨 OBLIGATOIRE À LA RACINE - Environment config
├── Makefile                    # 🚨 OPTIONNEL À LA RACINE - Development commands
├── var/                        # 🚨 OPTIONNEL À LA RACINE - Shared runtime data (gitignored)
│   ├── data/                   # Persistent data volumes
│   │   └── mariadb/            # Database data persistence
│   └── log/                    # Runtime logs from all containers
│       ├── app/                # Application logs
│       ├── traefik/            # Traefik logs
│       ├── mariadb/            # Database logs
│       └── supervisor/         # Process management logs
└── {user-specified-directory}/ # e.g., docker/, infra/, containers/
    ├── app/                    # ⭐ MANDATORY - Main application container
    │   ├── Dockerfile          # Multi-stage build (context: . dockerfile: ./docker/app/Dockerfile)
    │   ├── supervisord.conf    # Process management
    │   └── scripts/            # App-specific scripts
    ├── linter/                 # Code quality container (profile-based)
    │   └── Dockerfile          # Linting tools (context: . dockerfile: ./docker/linter/Dockerfile)
    ├── traefik/                # Reverse proxy container
    │   ├── traefik.yml         # Configuration
    │   └── certs/              # SSL certificates
    └── {database}/             # Database container (mariadb/, postgres/, etc.)
        ├── init/               # Initialization scripts
        └── conf.d/             # Custom configuration
```

## COPY vs Volume Mount Rules

### COPY Rules (What NOT to copy)
**🚨 COPY FORBIDDEN for:**
- Application code (`/app/*` directory)
- User-level configs (supervisord, workers, app configs)
- Frontend assets (CSS, JS, HTML)
- Environment files (`.env`, `settings.py`)

**✅ COPY ACCEPTABLE for:**
- System daemon configs (`/etc/mysql/`, `/etc/postgresql/`)
- Binary installations (`--from=node-tools`)
- Container-level configurations

### Volume Mount Strategy
```yaml
# docker-compose.yml
services:
  app:
    build: { context: ., dockerfile: ./docker/app/Dockerfile }
    volumes:
      - .:/app                                      # Code mount
      - ./docker/app/configs:/etc/configs:ro       # Container configs
      - ./var/data/uploads:/app/uploads             # Data persistence
      - ./var/log/app:/var/log/app                  # Log collection
```

## Build vs Dependencies Rules

### Development Optimization Rules
**🚨 Dependencies NOT in Dockerfile build for development:**
- Python packages (pip install) → Post-build via make dev-setup
- Node modules (npm install) → Post-build via make dev-setup
- PHP dependencies (composer install) → Post-build via make dev-setup
- System packages for development tools → OK in Dockerfile

**Benefits:**
- **Fast Docker builds** - Only runtime changes trigger rebuild (seconds vs minutes)
- **Instant code changes** - Volume mounts for immediate feedback
- **Cross-platform compatibility** - Dependencies installed in container environment

### Build Dependencies (Include in Dockerfile)
- System libraries (build-essential, libpq-dev)
- Runtime system packages (git, sudo, curl)
- Base tools (python3, node, php-fpm)

## Development Optimization Patterns

### Dependencies NOT in Dockerfile Build
**🚨 For development speed - manage post-build via Makefile:**

```dockerfile
# ❌ FORBIDDEN in dev Dockerfile
COPY package.json ./
RUN yarn install             # ❌ Slow rebuild on every dependency change

COPY composer.json ./
RUN composer install        # ❌ Slow rebuild on every dependency change

COPY requirements.txt ./
RUN pip install -r requirements.txt  # ❌ Slow rebuild on every dependency change
```

### Post-Build Dependency Management
```dockerfile
# ✅ Dockerfile - Runtime + system tools only
FROM python:3.12-slim
RUN apt-get update && apt-get install -y build-essential git nodejs npm
# No dependency installation in build!
```

```makefile
# ✅ Makefile - Dependencies post-build examples by stack
dev-setup:
	@echo "Installing dependencies..."
	$(RUN_APP) [pip|composer|npm] install  # Stack-appropriate
	$(RUN_APP) [python manage.py|php artisan|npm run] migrate

dev: dev-setup
	$(DOCKER_COMPOSE) up

update-deps:
	$(RUN_APP) [pip|composer|npm] install

clean-deps:
	$(RUN_APP) rm -rf node_modules __pycache__ vendor
```

### Development Benefits
- **Fast Docker builds** - Only runtime changes trigger rebuild (seconds vs minutes)
- **Fast dependency updates** - `make update-deps` without container rebuild
- **Instant code changes** - Volume mounts for immediate feedback
- **Better caching** - System tools vs application dependencies separation
- **Flexible workflows** - `make dev`, `make update-deps`, `make clean-deps`

## Docker Development Philosophy

### Core Principles
- **Docker as standard** unless explicitly contraindicated
- **Volume mounts mandatory** - COPY forbidden for application code and user-level configs
- **Single app container** - Embed frontend build in backend container, avoid over-containerization
- **Multi-project friendly** - `{service}.{project}.localhost` domains with `dev.project={PROJECT_NAME}` labels
- **Data in user directory** - Database volumes in user-specified folder (./var/data/)
- **Linting containers** - Separate linter containers to avoid version conflicts (profile-based)

## Troubleshooting

### Common Issues

**Permission denied on volumes:**
```bash
# Fix: Export UID/GID before docker commands
export UID && export GID=$(id -g)
```

**Port already in use:**
```bash
# Check what's using the port
lsof -i :8080
# Or modify ports in docker-compose.env-docker
```

**SSL certificate issues:**
```bash
# Regenerate certificates
make ssl-setup
# Or manually:
mkcert "{{PROJECT_NAME}}.localhost" "*.{{PROJECT_NAME}}.localhost"
```

**Domain resolution:**
```bash
# Add to /etc/hosts
echo "127.0.0.1 app.{{PROJECT_NAME}}.localhost" >> /etc/hosts
```

**Container won't start:**
```bash
# Check logs
docker compose logs app
# Rebuild from scratch
docker compose down -v && docker compose build --no-cache
```