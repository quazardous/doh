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

### Container Naming Convention
**@AI-Kitchen: Docker Compose container naming pattern**

Docker Compose automatically generates container names using the pattern:
`{project_name}-{service_name}-{replica_number}`

**Examples for project "doh":**
- `doh-app-1` - Main application container (service: app)
- `doh-frontend-1` - Frontend development server (service: frontend) 
- `doh-mariadb-1` - MariaDB database (service: mariadb)
- `doh-traefik-1` - Traefik reverse proxy (service: traefik)
- `doh-phpmyadmin-1` - Database admin interface (service: phpmyadmin)

**Environment Variable Reference:**
The main application container name is available as `APP_CONTAINER` in docker-compose.env:
```bash
# In docker-compose.env-docker template:
APP_CONTAINER={{PROJECT_NAME}}-app-1

# After processing (example for project "doh"):
APP_CONTAINER=doh-app-1
```

**Usage in commands:**
```bash
# Check container status
docker compose --env-file docker-compose.env ps

# Execute commands in specific containers
docker compose exec app bash                    # Uses service name
docker exec doh-app-1 bash                      # Uses container name
docker exec $APP_CONTAINER bash                 # Uses environment variable

# View logs
docker compose logs app                         # Uses service name  
docker logs doh-app-1                          # Uses container name
docker logs $APP_CONTAINER                      # Uses environment variable
```

**Note:** Always use service names with `docker compose` commands and container names with `docker` commands.

### Container User Naming Convention
**@AI-Kitchen: Modify existing users OR create 'appuser'**

**PRIORITY ORDER:**
1. **If system user exists (www-data, nginx, node)** - Modify its UID/GID
2. **If no suitable user exists** - Create 'appuser'

**Pattern 1: Modify existing user (PREFERRED):**
```dockerfile
# ✅ CORRECT - Modify existing www-data user for PHP containers
# UID and GID are set in the host/docker env
ARG UID
ARG GID
RUN usermod -u ${UID} www-data && \
    groupmod -g ${GID} www-data

# ✅ CORRECT - Modify existing node user for Node containers
RUN usermod -u ${UID} node && \
    groupmod -g ${GID} node
```

**Pattern 2: Create new user only if needed:**
```dockerfile
# ✅ CORRECT - Create appuser only when no standard user exists
RUN groupadd -g ${GID} appuser && \
    useradd -u ${UID} -g ${GID} -m appuser
```

**Common system users to modify (not create):**
- `www-data` - Apache/PHP containers
- `nginx` - Nginx official images  
- `node` - Node.js official images
- `postgres` - PostgreSQL images

**Rule:** Always prefer modifying existing users over creating new ones.

**Handling UID/GID conflicts:**
```dockerfile
# Safe modification pattern - handles existing UID/GID
RUN usermod -o -u ${UID} www-data && \
    groupmod -o -g ${GID} www-data
# -o flag allows non-unique UID/GID (prevents errors)
```

### Volume Mount Patterns
**@AI-Kitchen: COPY vs VOLUME rules**

**🚨 MANDATORY VOLUME MOUNT (never COPY):**
- **Application source code: `./:/app`** - ALL main containers MUST mount project root to `/app`
  - This includes ALL application code, configs, and user-level files
  - Enables instant code changes without container rebuilds
  - Dockerfile WORKDIR must be `/app` to match volume mount

**Always VOLUME mount (never COPY):**
- Data persistence: `./var/data/mariadb:/var/lib/mysql`
- Log directories: `./var/log/traefik:/var/log/traefik`

**Never COPY during build (handled post-build):**
- Dependencies: `requirements.txt`, `package.json` - installed via `make dev-setup`
- Supervisor config: `/app/docker/app/supervisor/supervisord.conf` - mounted with app code
- Application configs: Included in source code mount

**Always COPY (never VOLUME):**
- System daemon configs: `/etc/mysql/`, `/etc/postgresql/`, `/etc/nginx/`
- Container-level configurations that need to be baked into image

**Example:**
```dockerfile
# ✅ Correct - System daemon config
COPY ./docker/mysql-custom.cnf /etc/mysql/conf.d/

# ✅ Correct - WORKDIR must be /app to match volume mount
WORKDIR /app

# ❌ Wrong - Never COPY application code
COPY . /app

# ❌ Wrong - Dependencies should be installed post-build
COPY requirements.txt /app/
RUN pip install -r requirements.txt

# ✅ Correct - Dependencies installed after container running
# Via make dev-setup or docker exec
```

### Multi-stage Dockerfile Strategy
**@AI-Kitchen: CONDITIONAL stages based on detected technologies**

#### CMD Instruction Rules
**⚠️ IMPORTANT: Only ONE CMD per Dockerfile**
- Multiple CMD instructions are useless - only the LAST one is executed
- Each stage can have its own CMD, but only the final stage's CMD runs
- Use ENTRYPOINT + CMD for more flexibility if needed

```dockerfile
# ❌ WRONG - Multiple CMDs (only last one runs)
CMD ["python", "manage.py", "runserver"]
CMD ["yarn", "dev"]
CMD ["/usr/bin/supervisord"]  # Only this runs!

# ✅ CORRECT - Single CMD with supervisor managing all processes
CMD ["/usr/bin/supervisord", "-c", "/app/docker/app/supervisor/supervisord.conf"]
```

#### Multi-Stage Precedence Rules
**@AI-Kitchen: CRITICAL - Last stage wins**

Docker uses **REVERSE PRECEDENCE** in multi-stage builds:
- **Last stage defined = Default stage** (when no --target specified)
- Stages are processed **front-to-back** but **last stage becomes default**

```dockerfile
# ❌ WRONG - Frontend stage will be default (runs yarn dev)
FROM python:3.11-slim
RUN apt-get install supervisor
CMD ["/usr/bin/supervisord"]

FROM node:20-alpine AS frontend  # ← This becomes DEFAULT!
CMD ["yarn", "dev"]              # ← This CMD runs for app service
```

```dockerfile
# ✅ CORRECT - Main stage is default (runs supervisord)
FROM node:20-alpine AS frontend
CMD ["yarn", "dev"]

FROM python:3.11-slim           # ← This becomes DEFAULT!
RUN apt-get install supervisor
CMD ["/usr/bin/supervisord"]    # ← This CMD runs for app service
```

**Rule:** Put the **main application stage LAST** to make it the default.

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
CMD ["supervisord", "-c", "/app/docker/app/supervisor/supervisord.conf"]

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
**@AI-Kitchen: Critical permission setup - modify existing or create appuser**

```dockerfile
# Dockerfile Pattern 1: Modify existing user (PREFERRED)
# UID and GID are set in the host/docker env
ARG UID
ARG GID

# For PHP/Apache containers - modify www-data
RUN usermod -u ${UID} www-data && \
    groupmod -g ${GID} www-data && \
    chown -R www-data:www-data /var/www
USER www-data

# For Node containers - modify node user
RUN usermod -u ${UID} node && \
    groupmod -g ${GID} node
USER node

# Dockerfile Pattern 2: Create appuser (only if no standard user)
# UID and GID are set in the host/docker env
ARG UID
ARG GID

# For Python/custom containers - create appuser
RUN groupadd -g ${GID} appuser && \
    useradd -u ${UID} -g ${GID} -m -s /bin/bash appuser
USER appuser
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
│   ├── Dockerfile              # Multi-stage build (no COPY of deps/configs)
│   └── supervisor/
│       └── supervisord.conf    # User-level supervisor config (in app mount)
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
│   ├── supervisor/            # Supervisor process logs
│   ├── {database}/            # Database logs
│   └── traefik/               # Traefik access/error logs
├── run/
│   └── supervisor/            # Supervisor PID/socket files (optional)
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

## Supervisord User-Level Integration
**@AI-Kitchen: Process management without root privileges**

### User-Level Supervisor Pattern
Supervisor runs as the application user, not as a system service:

```dockerfile
# Dockerfile - NO supervisor config COPY
CMD ["/usr/bin/supervisord", "-c", "/app/docker/app/supervisor/supervisord.conf"]
```

```yaml
# docker-compose.yml - Config included in app mount
volumes:
  - .:/app  # Includes docker/app/supervisor/supervisord.conf
```

### Configuration Location
```bash
/app/
├── docker/
│   └── app/
│       └── supervisor/
│           └── supervisord.conf  # User-level config (version controlled)
└── var/
    ├── log/
    │   └── supervisor/           # Process logs
    └── run/
        └── supervisor/           # Socket/PID files (optional)
```

### Benefits
- **No root required** - Runs as app user
- **Version controlled** - Config in project repository
- **Dynamic reloads** - Change processes without rebuild
- **Developer friendly** - Direct `supervisorctl` access

### Usage Commands
```bash
# Check process status
docker exec app supervisorctl status

# Restart specific process
docker exec app supervisorctl restart django

# Start frontend dev server
docker exec app supervisorctl start frontend:*

# View process logs
docker exec app tail -f /app/var/log/supervisor/django.log
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
      - .:/app                                      # 🚨 MANDATORY - Project root to /app
      - ./docker/app/configs:/etc/configs:ro       # Container configs
      - ./var/data/uploads:/app/uploads             # Data persistence
      - ./var/log/app:/var/log/app                  # Log collection
```

**🚨 CRITICAL REQUIREMENT**: The main application container MUST have `- .:/app` volume mount:
- **ALL containers** that run application code require this mount
- **WORKDIR /app** in Dockerfile must match the volume mount path
- **Supervisord configs, application configs, source code** all accessible at `/app/`
- **Dependencies installed post-build** via `make dev-setup` within the `/app` context

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
- **🚨 MANDATORY `/app` mount** - ALL main containers MUST mount project root as `- .:/app` volume
- **Volume mounts mandatory** - COPY forbidden for application code and user-level configs
- **WORKDIR /app required** - Dockerfile WORKDIR must match the `/app` volume mount path
- **Single app container** - Embed frontend build in backend container, avoid over-containerization
- **Multi-project friendly** - `{service}.{project}.localhost` domains with `dev.project={PROJECT_NAME}` labels
- **Data in user directory** - Database volumes in user-specified folder (./var/data/)
- **Linting containers** - Separate linter containers to avoid version conflicts (profile-based)

## Troubleshooting

### Common Issues

**Application code not accessible in container:**
```bash
# Symptom: Container can't find application files
# Fix: Ensure volume mount is present
docker-compose.yml:
  app:
    volumes:
      - .:/app  # ← This line is MANDATORY
```

**Supervisord config not found:**
```bash
# Symptom: supervisord: can't find config file
# Fix: Config must be accessible via /app mount
CMD ["supervisord", "-c", "/app/docker/app/supervisord.conf"]
```

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