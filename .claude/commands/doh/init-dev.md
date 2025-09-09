---
allowed-tools: Bash, Glob, Grep, LS, Read, Write, Edit, MultiEdit, WebFetch
---

# Initialize Development Stack - Enhanced Docker Development Guide

AI-assisted guide to rapidly create modern and pragmatic Docker development environments. Combines intelligent stack analysis + DOH components + real-time best practices research + comprehensive validation.

> **🎯 OBJECTIVE:** Accelerate efficient Docker development with solid architectural patterns
> 
> **🧠 PHILOSOPHY:** Component "kitchen" + debug hints + AI self-correction to succeed even when AI doesn't get it perfect on first try

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

### Automated Installation

A helper script is available to install all host dependencies:

```bash
# Check available installation script (stable kitchen template)
.claude/templates/init-dev/common/scripts/install-deps.sh
```

This script handles:
- Docker installation using official distribution packages:
  - Ubuntu/Debian: Official Docker CE repository
  - Fedora/RHEL/CentOS: Official Docker CE repository  
  - Arch/Manjaro: Native pacman packages
  - openSUSE: Native zypper packages
  - macOS: Homebrew cask
- mkcert installation with platform-specific methods
- make and build-essential tools
- curl installation if missing
- Automatic Docker service enablement and user group configuration

### Manual Installation

💡 **Docker:**
- **macOS**: `brew install --cask docker` or Docker Desktop from docker.com
- **Ubuntu/Debian**: Official Docker repository via apt with docker-ce package
- **Fedora**: Official Docker repository via dnf with docker-ce package
- **RHEL/CentOS/Rocky/AlmaLinux**: Official Docker repository via yum
- **Arch/Manjaro**: `sudo pacman -S docker docker-compose`
- **openSUSE**: `sudo zypper install docker docker-compose`
- **Windows** (requires WSL2):
  1. Enable WSL2: PowerShell as Admin → `wsl --install` → Restart
  2. Install Docker Desktop with WSL2 engine enabled
  3. Configure WSL integration in Docker Desktop settings
  4. Use WSL2 terminal (Ubuntu) for all Docker commands

💡 **mkcert:**
- **macOS**: `brew install mkcert`
- **Linux with Homebrew**: `brew install mkcert` (if Linuxbrew installed)
- **Linux Ubuntu/Debian**: `sudo apt install libnss3-tools` + download from https://dl.filippo.io/mkcert/latest?for=linux/amd64
- **Linux Arch/Manjaro**: `sudo pacman -S mkcert`
- **Linux RHEL/Fedora**: `sudo yum install nss-tools` + download binary
- **Linux openSUSE**: `sudo zypper install mozilla-nss-tools` + download binary
- **Windows in WSL2**: Use Linux instructions above (Ubuntu recommended)
- **Windows native** (if needed): `choco install mkcert` or download from GitHub releases
  - Note: Prefer installing mkcert inside WSL2 for consistency

💡 **make:**
- **macOS**: `brew install make` or `xcode-select --install`
- **Linux with Homebrew**: `brew install make` (if Linuxbrew installed)
- **Linux Ubuntu/Debian**: `sudo apt install build-essential`
- **Linux Arch/Manjaro**: `sudo pacman -S base-devel`
- **Linux RHEL/Fedora**: `sudo yum groupinstall "Development Tools"`
- **Linux openSUSE**: `sudo zypper install make gcc`
- **Windows in WSL2**: Use Linux instructions above
- **Windows Git Bash**: Usually included with Git for Windows

## Usage
```
/doh:init-dev <natural language stack description>
/doh:init-dev "Python Django with PostgreSQL in ./docker directory"  
/doh:init-dev "Node.js React fullstack with MySQL and Redis"
/doh:init-dev "PHP Laravel API with PostgreSQL and background jobs"
/doh:init-dev "Python FastAPI microservice with MongoDB"
```

## AI Approach + Debug Hints

⚡ **AI-driven command** with integrated hint system to succeed even when AI fails on first attempt:

### 🗯 Debug Hints System (New Feature)

**Philosophy:** Developers will **INEVITABLY** need to debug/adjust, so we anticipate common problems:

```bash
# Hints automatically added to generated files:
# HINT: If permission denied -> check UID/GID in docker-compose.yml
# HINT: If build fails -> try 'make clean && make rebuild'
# HINT: If database connection fails -> check .env DATABASE_URL format
# HINT: Alternative stack configs at https://github.com/laradock/laradock
```

**Types of Integrated Hints:**
- 🔧 **Troubleshooting Hints:** Common Docker issues (permissions, ports, SSL)
- 🔄 **Alternative Hints:** Links to other approaches if DOH patterns don't fit
- 📚 **Resource Hints:** Official documentation, community examples
- 🚀 **Optimization Hints:** Performance, security, workflow improvements

### 🎯 AI Self-Correction

AI tests its own generations and self-corrects automatically:

### 1. Stack Analysis with Debug Hints

**Manual Mode** (`/doh:init-dev "Python Django..."`):
- Parse natural language description  
- Identify components from user input
- 💡 **HINT:** If description ambiguous → WebSearch "{{framework}} development setup 2024" to clarify
- 💡 **HINT ALTERNATIVE:** If unsatisfied → try Detection Mode: `/doh:init-dev --detect`

**Detection Mode** (`/doh:init-dev --detect`):
- **File Analysis:** Examine existing project files for technology indicators
  ```text
  package.json → Node.js/JavaScript stack
  requirements.txt → Python stack  
  composer.json → PHP stack
  Cargo.toml → Rust stack
  go.mod → Go stack
  ```
  💡 **HINT:** If detection fails → check extensions: `.py`, `.js`, `.php` in `/src` or `/app`
  💡 **HINT RESSOURCE:** Documentation patterns https://12factor.net/config
  
- **Dependency Analysis:** Parse dependency files for framework detection
  ```text
  Django in requirements.txt → Django framework
  express in package.json → Express.js framework
  laravel/framework in composer.json → Laravel framework
  ```
  💡 **HINT DEBUG:** If framework not detected → check versions in requirements.txt/package.json
  💡 **HINT ALTERNATIVE:** Manual override: `/doh:init-dev "Force Django avec PostgreSQL"`
  
- **README Analysis:** Extract technology mentions and setup instructions
- **Existing Docker Analysis:** Check current docker-compose.yml for services
- **Database Detection:** Look for database connection configs and migrations
  💡 **HINT:** If DB not detected → look in `settings.py`, `config/database.php`, `.env.example`

### 2. Cherry-Pick Templates avec Fallback Hints
- Analyze `.claude/templates/init-dev/` for relevant inspiration
- Select appropriate base templates (common/, stacks/, services/)
- Adapt template patterns to detected/requested stack

💡 **HINT ARCHITECTURE:** Templates = starting kitchen, NOT final solution
💡 **HINT DEBUG:** If template inadequate → check `.claude/templates/init-dev/stacks/{{your-framework}}/` for alternatives
💡 **HINT RESOURCE:** External inspiration: https://github.com/laradock/laradock, https://github.com/dunglas/symfony-docker
💡 **HINT CUSTOM:** Create your template in `.claude/templates/init-dev/stacks/custom/` for recurring needs

### 3. Research + Hints Ressources (Tech-Adaptive)
- **Mode Interactif:** WebSearch with tech-specific sources for latest recommendations
- **Mode Non-Interactif:** Use explicitly specified versions and tools only
- **Tech-Specific Sources:** Adapt research to technology ecosystem

💡 **HINT PERFORMANCE:** If WebSearch slow → use local cache or template default versions
💡 **HINT OFFLINE:** If no internet → use `.claude/templates/init-dev/offline-defaults.json`
💡 **HINT OVERRIDE:** Force specific version: `"Python 3.11 Django 4.2 with PostgreSQL 14"`

### Docker Hub API Version Detection

**API Pattern:** `https://hub.docker.com/v2/repositories/{namespace}/{image}/tags/?page_size=50`

**Version Logic:** Fetch tags → Filter semantic versions (X.Y.Z) → Exclude pre-releases → Sort by date → Select latest

**Fallback:** Docker Hub API → WebSearch (best practices only) → Template defaults

**Technology Sources:**
| Tech | Docker Hub API | WebSearch (Best Practices Only) |
|------|---------------|--------------------------------|
| PHP | `/library/php/tags/` | "PHP best practices site:php.net" |
| Python | `/library/python/tags/` | "Python best practices site:python.org" |
| Node.js | `/library/node/tags/` | "Node.js best practices site:nodejs.org" |
| Ruby | `/library/ruby/tags/` | "Ruby best practices site:ruby-lang.org" |
| Go | `/library/golang/tags/` | "Go best practices site:golang.org" |
| Rust | `/library/rust/tags/` | "Rust best practices site:rust-lang.org" |

**Framework Research (Best Practices Only):**
- Laravel/Django/Rails → Worker patterns, testing, dotenv integration
- WebSearch is **NOT** for versions, only for patterns and recommendations

**Testing Patterns Research (Best Practices Only):**
```text
WebSearch "{{framework}} test environment isolation best practices"
WebSearch "{{framework}} test database configuration patterns"  
WebSearch "{{framework}} dotenv test environment best practices"
WebSearch "{{framework}} test coverage configuration patterns"

🚨 NOTE: These searches focus on configuration patterns and best practices, 
         NOT on version detection or dependency resolution.
```

**Frontend Dotenv Integration Research (Best Practices Only):**
```text
WebSearch "webpack dotenv plugin best practices {{framework}}"
WebSearch "vite environment variables best practices {{framework}}"
WebSearch "{{framework}} frontend backend environment sync patterns"
WebSearch "frontend build environment variables best practices {{framework}}"

🚨 NOTE: These searches focus on integration patterns and configurations,
         NOT on tool versions or dependency management.
```

**Frontend Dotenv Implementation Patterns:**

**Webpack Integration (Real-World Example):**
```javascript
// webpack.config.js with dotenv-webpack
const Dotenv = require('dotenv-webpack');

new Dotenv({
  path: process.env.NODE_ENV === 'test' ? './.env.test' : './.env',
  safe: false,    // Use .env.example for validation if true
  systemvars: true // Include system environment variables
})
```

**Vite Integration:**
```javascript  
// vite.config.js with native loadEnv
const env = loadEnv(mode, process.cwd(), '');
if (mode === 'test') {
  Object.assign(process.env, loadEnv('test', process.cwd(), ''));
}
```

**Frontend Environment Variable Patterns:**
```bash
# Backend-Frontend Synchronization via Dotenv
VITE_API_URL=${API_URL}           # Vite prefix for client exposure
REACT_APP_API_URL=${API_URL}      # Create React App prefix
VUE_APP_API_URL=${API_URL}        # Vue CLI prefix  
NEXT_PUBLIC_API_URL=${API_URL}    # Next.js prefix
```

**Environment Routing Strategy:**
1. **Single Source:** Backend `.env` / `.env.test` files contain all variables
2. **Frontend Exposure:** Build tools (webpack/vite) expose prefixed variables to browser
3. **Test Isolation:** `.env.test` overrides for both backend and frontend during testing
4. **Build-Time Injection:** Environment variables embedded during build process

**Generated Environment Files:**
```bash
# Template-generated files with framework-specific adaptations:
.env                    # Development: FRONTEND_API_URL=http://localhost:8000, DOH_SECRET=abc123...
.env.test              # Testing: DATABASE_URL=sqlite:///var/test.db, QUEUE_DRIVER=sync
.env.example           # Documentation: All variables with example values

# Framework-specific frontend variable mapping:
React:     REACT_APP_API_URL=${FRONTEND_API_URL}     # Exposed to window.process.env
           REACT_APP_DOH_SECRET=${DOH_SECRET}        # Validation via frontend
Vue:       VUE_APP_API_URL=${FRONTEND_API_URL}       # Exposed to process.env
           VUE_APP_DOH_SECRET=${DOH_SECRET}          # Validation via frontend
Vite:      VITE_API_URL=${FRONTEND_API_URL}          # Exposed to import.meta.env
           VITE_DOH_SECRET=${DOH_SECRET}             # Validation via frontend
Next.js:   NEXT_PUBLIC_API_URL=${FRONTEND_API_URL}   # Exposed to process.env
           NEXT_PUBLIC_DOH_SECRET=${DOH_SECRET}      # Validation via frontend
```

**Framework-Specific Dotenv Cascading (AI-Driven Detection):**

**Symfony Pattern:** `APP_ENV=prod` → `.env` → `.env.local` → `.env.prod` → `.env.prod.local`
```javascript
// webpack.config.js for Symfony (AI-generated cascade simulation)
const env = process.env.APP_ENV || 'dev';
plugins: [
  new Dotenv({ path: './.env', safe: false, systemvars: true }),
  new Dotenv({ path: './.env.local', safe: false, systemvars: true, silent: true }),
  new Dotenv({ path: `./.env.${env}`, safe: false, systemvars: true, silent: true }),
  new Dotenv({ path: `./.env.${env}.local`, safe: false, systemvars: true, silent: true })
]
```

**Laravel Pattern:** `APP_ENV=production` → `.env` → `.env.production` (simpler cascade)
```javascript
// webpack.config.js for Laravel (AI-detected simpler pattern)
const env = process.env.APP_ENV || 'local';
plugins: [
  new Dotenv({ path: './.env', safe: false, systemvars: true }),
  new Dotenv({ path: `./.env.${env}`, safe: false, systemvars: true, silent: true })
]
```

**Django Pattern:** `DJANGO_SETTINGS_MODULE` → Single file routing (no cascade)
```javascript
// webpack.config.js for Django (AI-detected single file pattern)
const settingsModule = process.env.DJANGO_SETTINGS_MODULE || 'settings.dev';
const envFile = settingsModule.includes('test') ? '.env.test' : '.env';
plugins: [
  new Dotenv({ path: envFile, safe: false, systemvars: true })
]
```

**AI Research Pattern (Best Practices & Patterns Only):** 
```text
🚨 VERSION DETECTION: Use Docker Hub API exclusively for all versions:
   - Base images: https://hub.docker.com/v2/repositories/library/{image}/tags/
   - Service images: https://hub.docker.com/v2/repositories/{org}/{image}/tags/

📚 BEST PRACTICES RESEARCH: Use WebSearch for configuration guidance:
WebSearch "{{framework}} dotenv environment precedence best practices"
WebSearch "{{framework}} .env file loading cascade patterns"
WebSearch "{{framework}} production environment configuration patterns"
WebSearch "{{framework}} docker development setup best practices"
WebSearch "{{framework}} required system tools recommendations"

🔧 IMPLEMENTATION PRIORITY:
1. Docker Hub API → Latest stable versions (primary)
2. WebSearch → Configuration patterns (secondary)  
3. Template defaults → Offline fallback (tertiary)
```

### Dynamic Technology Pairing Strategy

**AI Runtime Association Logic:**
```text
🧠 AI dynamically determines best practices research at execution time:

1. Framework Detection → Statistical Database Pairing:
   Django detected → PostgreSQL (statistical preference) 
   → WebSearch "Django PostgreSQL best practices {current_year}"

2. Frontend + Backend Detection → Integration Pattern Research:
   React + Laravel detected → Inertia.js vs SPA decision
   → WebSearch "Laravel React integration best practices {current_year}"

3. Worker/Queue Detection → Broker Recommendation:
   Celery detected → Redis broker (statistical preference)
   → WebSearch "Django Celery Redis best practices {current_year}"

🚨 KEY PRINCIPLE: Let AI make fresh associations at runtime based on:
- Current ecosystem trends (via WebSearch)
- Project-specific context (detected files/patterns)
- Statistical preferences (hardcoded fallbacks only)
- Community adoption metrics (real-time research)

NO HARDCODED PAIRINGS - Let AI be smart and current!
```

### Technology Association Logic

**Proven Stack Combinations:**
| Stack | Research Focus |
|-------|---------------|
| Laravel + Vue + MySQL + Redis | Inertia.js, cache/queue patterns |
| Django + React + PostgreSQL + Celery | DRF, async tasks |
| Node.js + React + MongoDB + Redis | Next.js, session management |
| Spring Boot + Angular + PostgreSQL | Enterprise patterns |

**Anti-Patterns to Avoid:**
- Laravel + Angular → Templating conflicts → Use Laravel API + Angular SPA
- Django + PHP tools → Ecosystem conflicts → Keep Python-only
- Node.js + Synchronous MySQL → Performance issues → Use async/await
- Multiple frontend frameworks → Bundle bloat → Pick ONE
- Multiple DBs without purpose → Complexity → Single DB + Redis cache

**Detection Priority:** Framework → Database → Frontend → Workers → Conflict resolution
}
```

🎯 INTEGRATION PATTERN DETECTION:

SPA (Single Page Application) Pattern:
Backend detected + Frontend detected → API-first architecture
→ WebSearch "{backend} REST API best practices {frontend} integration"

Full-Stack Framework Pattern:  
Laravel/Django/Rails detected → Server-rendered with frontend integration
→ WebSearch "{framework} frontend integration best practices"

Microservices Pattern:
Multiple services detected → Container orchestration needed
→ WebSearch "{framework} microservices Docker best practices"

JAMstack Pattern:
Static generator + API detected → CDN + serverless patterns  
→ WebSearch "JAMstack best practices {detected_stack} deployment"
```

**Smart Default Selection Logic:**
```text
🧠 AI DECISION TREE:

Language Detected → Framework → Database → Frontend → Tools
     ↓                ↓          ↓          ↓         ↓
   Python    →    Django   → PostgreSQL → React  → pytest + black
     ↓                ↓          ↓          ↓         ↓
Statistics:        70%        70%        40%       90%

PHP       →    Laravel  →    MySQL   →   Vue    → PHPUnit + CS-Fixer  
     ↓                ↓          ↓          ↓         ↓
Statistics:        80%        60%        70%       85%

Node.js   →    Express  → PostgreSQL → React  → Jest + ESLint
     ↓                ↓          ↓          ↓         ↓  
Statistics:        60%        40%        80%       90%

Each decision includes:
- Statistical confidence level
- Community adoption metrics  
- Best practices research triggers
- Known pitfall warnings
```

**Framework-Specific Tool Requirements:**

🚨 **CRITICAL**: All framework-specific tools, CLI commands, project structures, and implementation patterns are documented in `.claude/templates/init-dev/FRAMEWORK_SPECIFICS.md`. 

**AI MUST read this file for:**
- Official CLI tools for each framework (django-admin, symfony, artisan, rails, etc.)
- Project structure conventions
- Environment variable management patterns  
- Hello-doh implementation specifics
- Dotenv cascade logic per framework

**Key Reference Points:**
- Framework CLI priority order and commands
- hello-doh target implementation patterns
- Environment variable naming conventions
- Project structure and file organization
- Dependency management approaches per framework

**Framework Tool Cascade Installation (AI-Adaptive):**

**Multi-Stage Pattern for Tool Cherry-Picking:**
```dockerfile
# AI detects stack → generates appropriate stages according to technology
FROM node:20 AS node-tools         # If frontend detected (Vue.js, React, Angular)
FROM composer:2 AS composer-tools   # 🚨 UNIQUEMENT SI PHP DÉTECTÉ (Laravel, Symfony)
FROM python:3.12 AS python-tools    # If Python detected (Django, FastAPI, Flask)

FROM php:8.3-fpm  # PHP final image (exemple pour stack PHP)

# Cherry-pick Node.js tools (AI-conditionnel - frontend frameworks)
COPY --from=node-tools /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-tools /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Cherry-pick Composer (🚨 UNIQUEMENT POUR PHP - Laravel/Symfony/etc.)
COPY --from=composer-tools /usr/bin/composer /usr/bin/composer

# System dependencies (AI-detected according to framework)
RUN apt-get update && apt-get install -y git sudo supervisor unzip
```

**Alternative Example for Python Stack:**
```dockerfile
# AI détecte stack Python → génère stages appropriés
FROM node:20 AS node-tools         # If frontend detected (Vue.js with Django)
FROM python:3.12 AS python-tools    # Pour Python/Django stack

FROM python:3.12-slim  # Python final image pour Django

# Cherry-pick Node.js tools (pour Vue.js frontend)
COPY --from=node-tools /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-tools /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# 🚨 PAS DE COMPOSER - car Python n'utilise pas Composer (outil PHP)
# Dependencies Python installées via pip APRÈS build (post-build pattern)

# Système dependencies pour Python
RUN apt-get update && apt-get install -y build-essential git python3-dev libpq-dev
```

**AI Stack Detection → Base Image Strategy:**
```text
📊 STRATEGY BY DETECTED TECHNOLOGY:

PHP (Laravel/Symfony):
├── Frontend détecté → FROM composer:2 + FROM node:20 → php:8.3-fpm
└── Backend seul → FROM composer:2 → php:8.3-fpm

Python (Django/FastAPI):  
├── Frontend détecté → FROM node:20 → python:3.12-slim
└── Backend seul → FROM python:3.12-slim

Node.js (Express/Nest):
└── Pur → FROM node:20-alpine (pas de multi-stage nécessaire)

Go:
├── Frontend détecté → FROM node:20 → golang:1.21-alpine  
└── Backend seul → FROM golang:1.21-alpine

Rust:
├── Frontend détecté → FROM node:20 → rust:1.70-slim
└── Backend seul → FROM rust:1.70-slim

Ruby (Rails):
├── Frontend détecté → FROM node:20 → ruby:3.2-slim
└── Backend seul → FROM ruby:3.2-slim

Java (Spring):
├── Frontend détecté → FROM node:20 → openjdk:21-slim
└── Backend seul → FROM openjdk:21-slim

.NET:
├── Frontend détecté → FROM node:20 → mcr.microsoft.com/dotnet/sdk:8.0
└── Backend seul → FROM mcr.microsoft.com/dotnet/sdk:8.0

🚨 RULE: AI selects tools according to detected technology matrix
```

**Tool Installation Strategy (Non-Template):**
- **AI Research:** WebSearch "{{framework}} docker development requirements"
- **Conditional Stages:** Créer stages seulement pour outils détectés
- **Cherry-Pick Pattern:** COPY --from= pour éviter bloat des base images  
- **Version Detection:** Utiliser versions officielles actuelles des images
- **System Tools:** git, sudo installés dans main stage
- **🚨 COPY Rules:** Only for system daemon configs (mysql, postgresql), NEVER for app code or user-level configs

**Worker/Daemon Detection & Integration:**
- **Single Container Philosophy:** Web server + workers + daemons in one container via supervisord
- **Alternative Avoided:** Multiple app containers (pollutes namespace, complicates dev workflow)
- **Supervisord Benefits:** Process management, log aggregation, unified container access via `make sh`

### 4. Translate to DOH Patterns avec Error Hints
- Apply DOH principles (Docker + Traefik + mkcert + Hello World)
- Ensure zero permission issues (UID/GID matching)
- Create project-specific service selection
- Generate working Hello World for validation

💡 **HINT PERMISSIONS:** If 403/permission errors → export UID && export GID=$(id -g) before $(DOCKER_COMPOSE)
💡 **HINT PORTS:** If port conflicts → modify EXTERNAL_HTTP_PORT/EXTERNAL_HTTPS_PORT in docker-compose.env  
💡 **HINT SSL:** If certificates invalid → rm -rf docker/certs/* && make ssl-setup
💡 **HINT TROUBLESHOOT:** Complete logs: make logs or $(DOCKER_COMPOSE) logs -f {{service}}

### Directory Customization & Container Organization

**🚨 IMPÉRATIF**: Docker Compose files at project root + container-organized structure:

- **docker-compose.yml**: ALWAYS at project root (context: . works correctly)
- **docker-compose.env**: ALWAYS at project root (same level as docker-compose.yml)
- User can specify container directory: "in ./docker" → creates structure in `./docker/app/`, `./docker/traefik/`
- Default: `./docker-dev/` (DOH standard) → creates structure in `./docker-dev/app/`, `./docker-dev/traefik/`
- **MANDATORY structure**: Each container gets its own sub-folder with proper build context

**Generated Structure (Container-Organized with docker-compose at root)**:
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

## Core Philosophy + Patterns de Debug

### COPY vs Volume Mount Rules + Debug Hints (STRICT)

**🚨 COPY FORBIDDEN for:**
- Application code (`/app/*` directory)
- User-level configs (supervisord, workers, app configs)
- Frontend assets (CSS, JS, HTML)
- Environment files (`.env`, `settings.py`)
- Anything owned by non-root users in container

💡 **HINT DEBUG COPY:** If code changes not visible → check volumes in docker-compose.yml
💡 **HINT ALTERNATIVE:** If volume mount problematic → try bind mounts or named volumes
💡 **HINT PERFORMANCE:** If volumes slow on Windows → try Docker Desktop WSL2

### Build vs Dependencies Rules + Troubleshooting (DEV OPTIMIZATION)

**🚨 Dependencies NOT in Dockerfile build for development:**
```dockerfile
# ❌ FORBIDDEN in dev Dockerfile
COPY package.json ./
RUN yarn install             # ❌ Slow rebuild on every dependency change

COPY composer.json ./
RUN composer install        # ❌ Slow rebuild on every dependency change

COPY requirements.txt ./
RUN pip install -r requirements.txt  # ❌ Slow rebuild on every dependency change
```

**✅ Dependencies managed post-build via Makefile:**
```dockerfile
# ✅ Dockerfile - Runtime + system tools only
FROM python:3.12-slim
RUN apt-get update && apt-get install -y build-essential git nodejs npm
# No dependency installation in build!
```

```makefile
# ✅ Makefile - Dependencies post-build examples by stack

# Stack-specific examples (all use $(RUN_APP) and $(DOCKER_COMPOSE) variables)
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

**Benefits + Debug Hints:**
- **Fast Docker builds** - Only runtime changes trigger rebuild (seconds vs minutes)
  💡 **HINT:** If build slow → check .dockerignore to exclude node_modules, .git, var/
- **Fast dependency updates** - `make update-deps` without container rebuild
  💡 **HINT:** If update fails → try `make clean-deps` then `make dev-setup`
- **Instant code changes** - Volume mounts for immediate feedback
  💡 **HINT:** If no hot-reload → check that framework supports it (webpack-dev-server, etc.)
- **Better caching** - System tools vs application dependencies separation  
- **Flexible workflows** - `make dev`, `make update-deps`, `make clean-deps`
  💡 **HINT:** If commands fail → check that containers are started: `$(DOCKER_COMPOSE) ps`

**✅ COPY ACCEPTABLE ONLY for:**
- System daemon configs (`/etc/mysql/`, `/etc/postgresql/`)
- Root-owned system files that NEVER change
- Binary installations from build stages

**📋 Examples:**
```dockerfile
# ❌ FORBIDDEN
COPY ./docker/supervisord.conf /etc/supervisor/supervisord.conf  # runs under 'app' user
COPY --chown=${UID}:${GID} . .                                  # application code
COPY ./src /app/src                                             # application code

# ✅ ACCEPTABLE  
COPY ./docker/mysql-custom.cnf /etc/mysql/conf.d/              # system daemon config
COPY --from=node-tools /usr/local/bin/node /usr/local/bin/     # binary installation
```

**📦 Volume Mount Strategy:**
```yaml
# 🚨 docker-compose.yml at project root, context: always "."
services:
  app:
    build: { context: ., dockerfile: ./docker/app/Dockerfile }
    volumes:
      - .:/app                                      # Code mount
      - ./docker/app/configs:/etc/configs:ro       # Container configs
      - ./var/log/app:/var/log/app                # Logs
  
  [linter|traefik|mariadb]:  # Same pattern for all services
    volumes: [code, configs, data, logs as appropriate]

# Organization: docker-compose.yml → root | Configs → ./docker/*/ | Data/logs → ./var/
```

### Docker-Focused & Pragmatic + Debugging
- **Docker as standard** unless explicitly contraindicated
  💡 **HINT:** If Docker problematic → alternatives: Vagrant, lima, podman, colima
- **Volume mounts mandatory** - COPY forbidden for application code and user-level configs
  💡 **HINT:** If volumes don't work → check Docker Desktop file sharing settings
- **Single app container** - Embed frontend build in backend container, avoid over-containerization
  💡 **HINT:** If too complex → separate containers example: https://github.com/laradock/laradock
- **Multi-project friendly** - `{service}.{project}.localhost` domains with `dev.project={PROJECT_NAME}` labels
  💡 **HINT:** If domains don't work → check /etc/hosts or use http://localhost:8080
- **Data in user directory** - Database volumes in user-specified folder (./var/data/)
  💡 **HINT:** If data lost → check volumes point to correct directory in docker-compose.yml
- **Linting containers** - Separate linter containers to avoid version conflicts (profile-based)
  💡 **HINT:** If linter fails → start with: `$(DOCKER_COMPOSE) --profile tools up -d linter`

### Template-Based Generation
- Uses templates from `.claude/templates/init-dev/`
- **Templates are illustrations** - versions and configs adapted at runtime
- Fetches current versions from official APIs
- Modular template system for stacks and services

## Implementation Workflow avec Debug Checkpoints

### 0. CRITICAL PREREQUISITES & PATTERN ENFORCEMENT

#### 🎯 AI EXECUTION ORDER (MANDATORY)

1. **READ & UNDERSTAND TEMPLATES FIRST**:
   - `.claude/templates/init-dev/common/Makefile.seed` → Foundation patterns (MANDATORY base)
   - `.claude/templates/init-dev/stacks/*/Makefile.*-part` → Framework additions only
   - `.claude/templates/init-dev/common/docker-compose-base.yml` → Docker patterns

2. **ENFORCE KITCHEN SYSTEM LOGIC**:
   - NEVER use direct Docker commands (`docker compose up`)
   - ALWAYS use predefined variables (`$(DOCKER_COMPOSE)`)
   - ALL Makefiles MUST include common patterns
   - Breaking these patterns = broken system

3. **VALIDATE MAKEFILE GENERATION**:
   - Start with Makefile.seed as foundation
   - Add framework-specific targets AFTER seed content
   - Result: ONE Makefile at root (not multiple includes)

#### 📋 MANDATORY IMPLEMENTATION PATTERNS

**1. ENVIRONMENT CONFIGURATION (`docker-compose.env` at root)**:
```bash
PROJECT_NAME=actual-project-name       # NOT {{PROJECT_NAME}}
EXTERNAL_HTTP_PORT=8080
EXTERNAL_HTTPS_PORT=4430  
EXTERNAL_TRAEFIK_PORT=8081
DOH_HELLOWORLD=abc123...               # 32-char generated secret
CONTAINER_DIR=./docker                 # User-specified or default
FRAMEWORK_NAME=Django                  # Detected/specified framework
DATABASE_NAME=PostgreSQL               # Detected/specified database
FRONTEND_NAME=React                    # If applicable
```

**2. MAKEFILE PATTERNS (Strict compliance required)**:
```makefile
# ALWAYS at top of EVERY Makefile:
-include docker-compose.env
DOCKER_COMPOSE = docker compose --env-file ./docker-compose.env
EXEC_CONTAINER = docker exec -it
EXEC_APP = $(EXEC_CONTAINER) $(APP_CONTAINER)

# NEVER:
docker compose up                      # ❌ FORBIDDEN
# ALWAYS:
$(DOCKER_COMPOSE) up                   # ✅ REQUIRED

# Complete manual pattern (when not using Makefile variables):
# export UID && export GID=$(id -g) && docker compose --env-file ./docker-compose.env up
```

**3. PERMISSION HANDLING (UID/GID)**:
```yaml
# docker-compose.yml
services:
  app:
    build:
      args: {UID: "${UID:-1000}", GID: "${GID:-1000}"}
    user: "${UID:-1000}:${GID:-1000}"
```

**4. TEMPLATE FILES (-docker suffix = working defaults)**:
```text
traefik.yaml-docker:  Contains port 8080 (working default)    ✅
docker-compose.env-docker: Contains real values               ✅
NOT: {{PROJECT_NAME}} or {{PLACEHOLDERS}}                     ❌ FAILURE

Local copies can be tweaked if defaults don't work (port conflicts, etc.)
```

#### ✅ AI VALIDATION CHECKLIST

**PRE-GENERATION CHECKS:**
- [ ] Read kitchen templates from `.claude/templates/init-dev/`
- [ ] Read Makefile.seed foundation patterns
- [ ] Identified all {{placeholders}} to substitute

**GENERATION VALIDATION:**
- [ ] Generated `-docker` files with ALL placeholders substituted
- [ ] `docker-compose.env-docker` has real values (my-project, port 8080, etc.)
- [ ] `traefik.yaml-docker` has real project name, not {{PROJECT_NAME}}
- [ ] `.env-docker` generated with working defaults
- [ ] **CRITICAL: HIGH-QUALITY Makefile at root - the main testing tool**
- [ ] Makefile preserves complete Makefile.seed content EXACTLY
- [ ] Framework additions are AFTER seed content (clean diff)
- [ ] `diff Makefile.seed Makefile` shows only logical additions
- [ ] `hello-doh` target works perfectly (creates + tests everything)
- [ ] All targets use seed patterns ($(DOCKER_COMPOSE), etc.)
- [ ] UID/GID handling in docker-compose.yml + Dockerfile

**CRITICAL FAILURE = STOP IF:**
- Any {{placeholder}} remains in generated -docker files
- Direct `docker compose` commands used (instead of predefined variables)
- Missing `-include docker-compose.env` in Makefiles
- Missing `env-config` target or dependency

#### ⚠️ CONSEQUENCES OF PATTERN VIOLATIONS

```text
Pattern Violation          →  Consequence
─────────────────────────────────────────
Direct docker commands     →  Environment variables not loaded
{{PROJECT_NAME}} in files  →  Services fail to start
Missing UID/GID           →  Permission denied errors  
No -include statement     →  Variables undefined
Wrong DOCKER_COMPOSE      →  Inconsistent behavior
```

**REMEMBER**: The kitchen system is a carefully orchestrated set of patterns. Breaking ANY pattern breaks the ENTIRE system.

### 1. Analyze Request & Research Stack + Hints

🚨 **CRITICAL**: AI MUST first read `.claude/templates/init-dev/FRAMEWORK_SPECIFICS.md` to understand framework-specific patterns, CLI tools, and implementation details before proceeding.

#### 📦 KITCHEN SYSTEM - THREE-STAGE TEMPLATE PROCESS

**The Kitchen Process Flow:**

```text
═══════════════════════ AI GENERATION TIME ═══════════════════════

Stage 1: KITCHEN TEMPLATES (.claude/templates/init-dev/)
         ↓ Contains {{placeholders}}
         ↓ AI reads and processes during /doh:init-dev
         ↓
Stage 2: GENERATED -docker FILES (in new project)
         ↓ AI substitutes placeholders with real values
         ↓ Committed to project git with working defaults
         ↓ Project is ready to share/clone

═══════════════════ DEVELOPER USAGE TIME ═══════════════════════

Stage 3: LOCAL FILES (when developer clones project)
         ↓ Developer runs: git clone && make dev-setup
         ↓ Makefile's env-config copies -docker → local
         ↓ Developer can customize (gitignored)
```

**Detailed Process:**

**1. KITCHEN TEMPLATES** (in `.claude/templates/init-dev/`):
```yaml
# traefik.yaml template - has {{placeholders}}
network: "{{PROJECT_NAME}}-network"
constraints: "Label(`dev.project`, `{{PROJECT_NAME}}`)"
```

**2. AI GENERATES `-docker` FILES** (in project with real values):
```yaml
# traefik.yaml-docker - AI substituted real values
network: "my-django-app-network"
constraints: "Label(`dev.project`, `my-django-app`)"
# Working defaults: port 8080, real project name, etc.
```

**3. LOCAL CUSTOMIZABLE FILES** (created when developer clones & runs project):
```yaml
# traefik.yaml - created by `make dev-setup` in the cloned project
network: "my-django-app-network"
# Developer can change port to 8090 if 8080 is busy
# This happens in the developer's environment, NOT during AI generation
```

**File Naming Convention:**
```text
Kitchen Template         → Generated File        → Local File
────────────────────────────────────────────────────────────
traefik.yaml (template) → traefik.yaml-docker   → traefik.yaml
docker-compose.env      → docker-compose.env-docker → docker-compose.env
.env (template)         → .env-docker            → .env
```

**Developer's Workflow (in the cloned project):**
```bash
# Developer clones the AI-generated project
git clone my-django-project
cd my-django-project

# Project contains:
# - Makefile (with env-config target)
# - traefik.yaml-docker (with real values)
# - docker-compose.env-docker (with real values)
# - .env-docker (with real values)

# Developer runs:
make dev-setup  # This triggers env-config first

# env-config creates local files (first time only):
# traefik.yaml-docker → traefik.yaml
# docker-compose.env-docker → docker-compose.env
# .env-docker → .env

# Developer can now customize local files if needed
```

**AI Generation Requirements:**
1. Read kitchen templates with {{placeholders}}
2. Generate `-docker` files with ALL placeholders substituted
3. Ensure `-docker` files have working defaults that run immediately
4. **CRITICAL: Generate the BEST possible main Makefile at root:**
   - Start with complete Makefile.seed content (foundation) - PRESERVE EXACTLY
   - Add framework-specific targets AFTER seed content
   - Include comprehensive hello-doh implementation
   - **Diff requirement: `diff Makefile.seed Makefile` should show ONLY clean additions**
   - NOT a completely different file - just logical framework extensions
   - This Makefile is THE MAIN TOOL to test the entire stack
5. Makefile MUST follow seed patterns EXACTLY
6. Commit only -docker files, never local files

**What AI should NOT do:**
- Do NOT add .gitignore entries (developer will manage their .gitignore)
- Do NOT create local files directly (only -docker templates)
- Do NOT override Makefile.seed patterns

**AI Testing Process:**
- Generate -docker files and THE BEST POSSIBLE Makefile
- Run `make env-config` to create local files from -docker templates
- Run `make dev-setup` to install dependencies
- Run `make hello-doh` to test complete stack functionality
- The Makefile quality determines testing success - invest heavily in making it perfect
- This validates: -docker → env-config → local files → containers → framework → hello-doh

**Makefile Generation Process:**
```makefile
# Final ROOT Makefile = Exact Makefile.seed + Clean Framework additions

# ========== EXACTLY FROM Makefile.seed (NO CHANGES) ==========
# DOH Makefile Seed - Foundation Patterns & Variables
export UID := $(shell id -u)
export GID := $(shell id -g)
DOCKER_COMPOSE = docker compose --env-file ./docker-compose.env
EXEC_CONTAINER = docker exec -it
# ... (complete seed content preserved exactly) ...
env-config:
    # copies -docker files to local
# ========== END: Exact seed content ==========

# ========== Framework additions (diff shows ONLY these) ==========
# Django-specific targets
django-init: ## Initialize Django project
    $(DOCKER_COMPOSE) run --rm app django-admin startproject myproject .

hello-doh: ## Test complete Django stack
    $(DOCKER_COMPOSE) run --rm app python manage.py doh_hello_world
    # Test web endpoint, database, etc.
```

**Expected diff output:**
```diff
# Only additions should appear in diff - no modifications to seed content
+ # =================================================================
+ # DJANGO-SPECIFIC CONFIG INITIALIZATION (extends seed env-config)
+ # =================================================================
+ 
+ env-config: ## Copy Django-specific -docker config files + common ones
+     # Common files from Makefile.seed (traefik, docker-compose.env)
+     # Django-specific files (.env, requirements.txt, settings/local.py)
+ 
+ # Django-specific targets  
+ django-init: ## Initialize Django project
+     $(DOCKER_COMPOSE) run --rm app django-admin startproject myproject .
+ 
+ hello-doh: ## Test complete Django stack
+     $(DOCKER_COMPOSE) run --rm app python manage.py doh_hello_world
```

**Framework-Specific Target Extensions:**
*-part files can redefine targets like `env-config` to add framework-specific files. AI must MERGE these with seed targets:

```makefile
# In Makefile.django-part: ONLY Django additions (AI merges with seed)
env-config: ## Initialize local config files from -docker templates (Django + common)
    # ⚠️ AI KITCHEN: MERGE this with Makefile.seed env-config target
    # This adds Django-specific files to the common ones from seed
    $(call copy-dist-config,./.env-docker,./.env)
    $(call copy-dist-config,./requirements.txt-docker,./requirements.txt)
    $(call copy-dist-config,./myproject/settings/local.py-docker,./myproject/settings/local.py)
```

**AI Kitchen Process:**
1. Start with seed `env-config` (common files: traefik, docker-compose.env)
2. Add Django-part `env-config` content (Django-specific files)
3. Result: Combined target with both common + framework files

#### 🏷️ @AI-Kitchen: Pseudo Tag System

**UNIVERSAL USAGE**: Kitchen templates use a standardized pseudo tag system in **ALL file types** to guide AI generation.

**@AI-Kitchen: ACTION_TYPE - DESCRIPTION**

**Action Types:**
- `@AI-Kitchen: MERGE` - Combine this target with seed version (Makefiles)
- `@AI-Kitchen: CHOOSE` - Make intelligent decision (package manager, database, versions)
- `@AI-Kitchen: SUBSTITUTE` - Replace placeholders with real values (all files)
- `@AI-Kitchen: CONDITIONAL` - Include/exclude based on stack requirements (all files)
- `@AI-Kitchen: GENERATE` - Create additional code/config files (app code)

**Examples by file type:**
```makefile
# Makefile comments
# @AI-Kitchen: MERGE - Add to seed env-config target
# @AI-Kitchen: CHOOSE - npm/yarn/pnpm based on lock files

# @AI-Kitchen: CONDITIONAL - Include if frontend stack detected
# Example: @${EXEC_CONTAINER} ${APP_CONTAINER} npm install
```

```yaml
# Docker Compose comments  
# @AI-Kitchen: SUBSTITUTE - Replace with actual database name
database: postgresql  # @AI-Kitchen: CHOOSE - postgresql/mysql/mariadb
```

```dockerfile
# Dockerfile comments
# @AI-Kitchen: CONDITIONAL - Include if Python stack
RUN pip install -r requirements.txt

# @AI-Kitchen: SUBSTITUTE - Replace with detected Node version
FROM node:18-alpine
```

```php
<?php
// @AI-Kitchen: GENERATE - Create controller with DOH_HELLOWORLD endpoint
// @AI-Kitchen: SUBSTITUTE - Replace with actual project namespace
```

```json
{
  // @AI-Kitchen: SUBSTITUTE - Replace with detected project name
  "name": "{{PROJECT_NAME}}",
  // @AI-Kitchen: CHOOSE - npm/yarn/pnpm based on lock files detection
  "scripts": {
    "dev": "npm run dev"  
  }
}
```

```env
# @AI-Kitchen: SUBSTITUTE - Replace with generated random value
DOH_HELLOWORLD={{DOH_HELLOWORLD}}
# @AI-Kitchen: CONDITIONAL - Include only if database detected
DATABASE_URL={{DATABASE_URL}}
```

```nginx
# @AI-Kitchen: SUBSTITUTE - Replace with actual project name
server_name {{PROJECT_NAME}}.localhost;
# @AI-Kitchen: CONDITIONAL - Include SSL config only if HTTPS enabled
```

**Generated Help System:**
All targets with `##` comments automatically appear in `make help`:
```bash
$ make help
🐍 Django + PostgreSQL + React Development
=================================================================

🚀 Quick Start:
   make ssl-setup    - Setup SSL certificates
   make django-init  - Initialize Django project
   make dev-setup    - Install all dependencies
   make dev          - Start development environment

Available Commands:
   env-config       Initialize local config files from -docker templates
   dev              Start development environment  
   dev-setup        Install all dependencies (Django + Node.js if needed)
   django-init      Initialize Django project with django-admin startproject
   hello-doh        Create Django Hello World app and test complete stack
   # ... all targets with ## comments
```

**Key Understanding:**
- AI generates → -docker files with real values
- Developer uses → Makefile creates local files from -docker
- Separation → AI generation vs Developer customization

**Natural Language Processing:**
```text
Input: "Python Django with PostgreSQL in ./docker directory"
→ Stack: Python + Django  
→ Database: PostgreSQL
→ Directory: ./docker/
→ Inferred needs: Web framework + ORM + Database + Testing + Linting
→ Check FRAMEWORK_SPECIFICS.md for Django-specific patterns
```

**AI Research:** WebSearch best practices → Docker Hub versions → PyPI trends → Template selection
💡 **Fallback:** Offline defaults → Standard stacks (black+flake8+mypy) → Generic templates

### 2. Generate Stack-Specific Configuration + Debug Checkpoints

**AI Decisions:** Linters (black+flake8+mypy) → Testing (pytest) → Version compatibility → Database client → hello-doh implementation
  
**🚨 CRITICAL: Every stack MUST include a working `hello-doh` target in Makefile. See `.claude/templates/init-dev/FRAMEWORK_SPECIFICS.md` for complete implementation details per framework including:**
- Framework CLI commands to use (make:controller, startapp, generate, etc.)
- Project structure conventions and file locations
- Environment variable patterns and dotenv cascade logic
- Hello-doh web + CLI implementation specifics
- DOH_HELLOWORLD validation patterns

**Dynamic Template Processing:**
```text
Template Pattern → Generated Reality
{{PROJECT_NAME}} → django-blog-api
{{PYTHON_VERSION}} → 3.12-slim (latest stable)
{{DJANGO_VERSION}} → 5.0 (from research)
{{DB_SERVICE}} → postgres (user specified)
{{DIRECTORY}} → ./docker/ (user specified)
```

### 3. Create DOH-Compliant Stack

**Essential Components:**
- Docker Compose + Traefik → `./var/log/traefik/` | Check ports 8080/443
- SSL mkcert → `mkcert -install` then `make ssl-setup`
- UID/GID → `export UID && export GID=$(id -g)`
- Multi-project domains → `app.{project}.localhost` or localhost:ports
- Makefile targets → dev, sh, hello-world
- Hello World validation → Console + Web endpoints

**Stack Components:**
- Linter container → `$(DOCKER_COMPOSE) --profile tools up -d linter`
- Testing → Check .env.test
- Dependencies → `make clean-deps && make dev-setup`
- Database → `./var/log/[mysql|postgres]/`
- Dotenv → Restart after .env changes
- Supervisord → `supervisorctl status` | `./var/log/supervisor/`

💡 **Debug Path:** Logs in `./var/log/*/` | `make logs` | `make sh` for manual testing

**Directory Structure:**
```
Root: docker-compose.yml, docker-compose.env, Makefile
./docker/: app/, linter/, traefik/, [db]/ → Container configs
./var/: data/, log/ → Runtime (gitignored)
```
### 4. AI-Driven Stack Implementation

**This is where the magic happens** - the AI analyzes the specific request, researches best practices, and creates a tailored development environment:

#### Example: Manual Mode - "Python Django with PostgreSQL in ./docker directory"

1. **Natural Language Analysis:**
   - Stack: Python + Django framework
   - Database: PostgreSQL specified
   - Directory: ./docker/ (custom location)

2. **Tech-Adaptive Research:**
   - "Django 2024 development best practices site:djangoproject.com"
   - "Python 3.12 latest stable site:python.org" + PyPI package trends
   - "Django testing pytest vs unittest" + community analysis
   - Docker Hub: python:3.12-slim availability check

#### Example: Detection Mode - `--detect`

1. **Project File Scan:**
   ```text
   Found Files → Analysis
   requirements.txt → Python stack detected
   Django==4.2.7 in requirements.txt → Django framework  
   psycopg2==2.9.7 in requirements.txt → PostgreSQL database
   manage.py → Django project structure confirmed
   README.md mentions "Django API" → Confirms web API project
   ```

2. **AI Synthesis with Statistical Defaults:**
   ```text
   Detection Results → Stack Configuration
   • Framework: Django 4.2 (preserve existing version)
   • Database: PostgreSQL (from psycopg2 + Python→PostgreSQL statistical pairing)
   • Linters: black + flake8 + mypy + isort (Python ecosystem standard)
   • Testing: pytest + pytest-django (community preference over unittest)
   • Directory: ./docker-dev/ (DOH default, unless specified)
   
   Statistical Logic Applied:
   Django detected → PostgreSQL default (coherent marriage)
   Python ecosystem → black/flake8/mypy standard linting stack
   ```

3. **Dynamic Template Processing:**
   - Cherry-pick from `.claude/templates/init-dev/stacks/python/`
   - Adapt `.claude/templates/init-dev/services/postgres.yml`  
   - Customize `.claude/templates/init-dev/common/Makefile` with Django commands
   - Generate requirements.txt with researched optimal dependencies

4. **File Generation Process (Container-Organized Structure):**
   ```text
   AI Creates:
   • ./docker-compose.yml → Single app container + services at project root (NO separate vue container)
   • ./docker-compose.env → Project config at project root with proper volume mounts
   • ./docker/app/Dockerfile → Python 3.12-slim with Node.js (NO COPY of app code)
   • ./docker/app/supervisord.conf → Web server + Celery workers configuration (volume mounted)
   • ./docker/linter/Dockerfile → Separate linter container with black/flake8/mypy/isort
   • ./docker/scripts/install-deps.sh → Dependency installation script (shared)
   • ./docker/traefik/traefik.yml → HTTPS routing configuration
   • ./docker/mariadb/init/01-create-database.sql → Database initialization
   • ./docker/Makefile → Enhanced with Django + Vue + worker commands + hello-world target
   • ./requirements.txt → Django 5.2 + mysqlclient + celery + pytest-django + linters
   • ./src/hello_world.py → Django Hello World view + management command
   • ./manage.py hello → Console Hello World command + Celery status check
   • ./INITDEV.md → Quick start guide with container-organized architecture
   • ./.env.test → Test configuration (SQLite, in-memory cache, sync queues)
   
   Volume Strategy (Container-Aware):
   • ..:/app → ALL application code (Django + Vue.js)
   • ./docker/data/mariadb:/var/lib/mysql → Data in user-specified directory
   • ./docker/app/supervisord.conf:/etc/supervisor/supervisord.conf:ro → Config volume
   • ./docker/traefik/traefik.yml:/etc/traefik/dynamic/traefik.yml:ro → Traefik config volume
   • ./docker/traefik/certs:/etc/ssl/certs:ro → SSL certificates volume
   ```

**Worker Integration Examples (with Process Groups):**
```text
Django + Celery detected → supervisord.conf with:
[group:web]
- gunicorn (web server)

[group:workers]  
- celery worker (async tasks)
- celery beat (scheduler)

Laravel + Queue detected → supervisord.conf with:
[group:web]
- php-fpm (web server)

[group:workers]
- php artisan queue:work (worker)

Rails + Sidekiq detected → supervisord.conf with:
[group:web]
- puma (web server)

[group:workers]
- sidekiq (background jobs)
```

**Supervisord Group Benefits:**
- **Granular Control:** `supervisorctl restart web:*` vs `supervisorctl restart workers:*`
- **Makefile Integration:** `make restart-web`, `make restart-workers`, `make restart-all`
- **Development Workflow:** Restart web server without killing long-running workers
- **Process Isolation:** Web failures don't affect worker processes

5. **Stack Confirmation (Interactive Mode):**
   ```text
   🧠 Brainstormed Stack Configuration:
   
   📦 Technology: Python Django 5.0
   🗄️ Database: PostgreSQL 16
   🧪 Testing: pytest + pytest-django
   🎨 Linting: black + flake8 + mypy + isort
   📁 Directory: ./docker/
   🌐 Domain: https://app.{project}.localhost
   
   ❓ CONFIRMATION REQUIRED:
   ✅ Proceed with this configuration? (y/N)
   
   Options:
   - y: Continue with proposed stack
   - N: Abort operation (default)
   - PostgreSQL: Change to PostgreSQL instead
   - React: Change to React instead of Vue  
   - custom: Specify your modifications
   ```
   
   **🚨 CRITICAL: The AI must STOP and WAIT for user response. Never proceed without explicit confirmation!**

## Command Options

### Interactive Mode (Default)
```bash
/doh:init-dev "Python Django with PostgreSQL in ./docker directory"
# → Shows brainstormed configuration and WAITS for user confirmation
# → User MUST respond: y/N, custom modifications, or abort
# → NEVER proceeds without explicit user approval
```

### Non-Interactive Mode (For Agents)
```bash
/doh:init-dev --non-interactive "Python Django with PostgreSQL in ./docker directory"
# → Proceeds immediately without confirmation prompts
# → Perfect for automated workflows and agent execution
# → ONLY use when user explicitly requests non-interactive mode
```

### Detection Mode (Auto-Analyze Existing Project)
```bash
/doh:init-dev --detect
# → Analyzes existing codebase to determine technology stack
# → Similar to Claude Code's /init command behavior
# → Examines package.json, requirements.txt, composer.json, README, etc.

/doh:init-dev --detect --non-interactive
# → Auto-detects and proceeds without confirmation
# → Perfect for automated project setup
```

## Why AI-Driven Approach?

**Dynamic Requirements:** Evolving best practices | Changing tools | Framework variations | User preferences | Real-time trends

**Interactive Mode:** WebSearch + **MANDATORY user confirmation** (y/N) + Modifications supported
**Non-Interactive Mode:** Explicit specs required, abort if unclear

**AI Advantages:** Real-time research | Context-aware | Template adaptation | Version detection | Self-validation

💡 **Fallbacks:** Offline defaults | Manual overrides | Template customization | Stable versions on failure

## Testing Strategy

**Test Environment Injection:** Container vars → Dotenv routing → Makefile commands

**Stack Variables:** Laravel=`APP_ENV=testing` | Symfony=`APP_ENV=test` | Django=`DJANGO_SETTINGS_MODULE` | Rails=`RAILS_ENV=test` | Node=`NODE_ENV=test`

💡 **Debug:** Check docker-compose.yml `environment:` → .env cascade → Manual: `$(DOCKER_COMPOSE) exec -e APP_ENV=testing app pytest`
- **Makefile** test commands with environment injection
  💡 **HINT:** If test command fails → run manually to see exact error
- **Test isolation** via in-memory/SQLite databases
  💡 **HINT:** If isolation broken → check that test DB != dev DB in configs
- **Coverage reports** in `./var/coverage/`
  💡 **HINT:** If no coverage → check that `./var/` writable + coverage installed

## Final Output & Testing

### 1. Hello World Implementation (AI Success Criteria)

**🎯 CRITICAL: Stack creation is NOT complete until ALL Hello Worlds work!**

💡 **HINT DEBUG HELLO WORLD:** If Hello World fails, follow this debug sequence:
1. `make logs` → checker logs de tous les services
2. `make sh` → entrer dans container et tester manuellement
3. Check `./var/log/app/`, `./var/log/traefik/`, `./var/log/supervisor/`
4. Tester composants un par un: DB connection, web server, routing Traefik

**Multi-Techno Hello World Strategy:**
- **Backend Priority:** Main framework that handles database connections
- **Frontend Bonus:** Additional Hello World if frontend detected (React, Vue, etc.)
- **Database Required:** Hello-DB test if database present

**Console Command (CLI validation - Framework Native):**
```bash
# Framework-specific console commands via native CLI systems
make sh
# Then inside container:
php bin/console app:hello-world         # Symfony Console Component
php artisan doh:hello-world            # Laravel Artisan
python manage.py doh_hello_world        # Django Management Command
rails runner "puts 'Hello DOH!'"       # Rails Runner
npm run doh:hello                       # Node.js (package.json script)
bundle exec rake doh:hello              # Ruby/Rake task

# Expected output:
# Hello DOH! Stack: Django + MariaDB + Vue.js
# DOH_SECRET: a1b2c3d4e5f67890abcdef1234567890
# Timestamp: 2025-01-08T14:30:45Z
```

**Web Endpoint (HTTP validation):**
```bash
# Test backend web hello world endpoint (priority)
curl -k https://app.{project}.localhost/hello
# Expected: {
#   "message": "Hello from Django on DOH!",
#   "stack": "Django + MariaDB + Vue.js", 
#   "doh_secret": "a1b2c3d4e5f67890abcdef1234567890",
#   "timestamp": "2025-01-08T14:30:45Z"
# }

# Frontend Hello World (if applicable)  
curl -k https://app.{project}.localhost/
# Expected: React/Vue app showing "Hello DOH!" + DOH_SECRET
# This validates: .env → docker-compose.yml → frontend build → browser exposure
```

**Database Hello World (Framework Native CLI):**
```bash
# Test database connectivity via framework console systems
make sh
# Then inside container:
php bin/console app:hello-db                    # Symfony Console (doctrine connectivity)
php artisan doh:hello-db                       # Laravel Artisan (eloquent connectivity)  
python manage.py doh_hello_db                  # Django Management (ORM connectivity)
rails runner "ActiveRecord::Base.connection.execute('SELECT 1')"  # Rails
npm run doh:hello-db                           # Node.js (package.json script with ORM)
```

**Worker Hello World (if workers detected):**
```bash
# Test worker processes via supervisord groups
make sh
# Then inside container:
supervisorctl status                     # Show all processes
supervisorctl status web:*               # Show only web processes  
supervisorctl status workers:*           # Show only worker processes

# Test specific workers
python manage.py celery inspect active  # Django Celery
php artisan queue:restart               # Laravel Queue
bundle exec sidekiq-cron                # Rails Sidekiq
```

**Makefile Process Management Integration:**
```bash  
# Generated Makefile includes:
make restart-web        # supervisorctl restart web:*
make restart-workers    # supervisorctl restart workers:*  
make restart-all        # supervisorctl restart all
make status            # supervisorctl status
make logs-web          # supervisorctl tail web:*
make logs-workers      # supervisorctl tail workers:*

# Alternative debugging (bypass supervisord):
make worker-debug       # celery worker in foreground with debug logs
make worker-shell       # separate shell for manual worker debugging  
make worker-inspect     # inspect active tasks and worker stats
```

**Debugging Flexibility:**
- **Supervisord (production-like):** Multiple workers managed automatically
- **Manual debugging:** Single worker in foreground with full debug output
- **Separate shells:** `$(DOCKER_COMPOSE) run` for isolated debugging sessions
- **Inspector tools:** Real-time task and worker monitoring

**AI Self-Validation Process + Debug Escalation (3 attempts max):**
1. **Generate stack files** (-docker templates + Makefile with seed foundation)
   💡 **HINT:** If generation fails → check templates source + write permissions
2. **Run `make env-config`** → Create local files from -docker templates
   💡 **HINT:** This tests the kitchen process: -docker → local files
3. **Run `make dev`** → Start Docker containers 
   💡 **HINT:** If make dev fails → `export UID && export GID=$(id -g)` then retry
4. **Run `make dev-setup`** → Install dependencies post-build (pip, composer, npm, etc.)
   💡 **HINT:** Must complete BEFORE any hello world tests - dependencies required
5. **Test framework hello** → Verify official framework hello world works (Django welcome, Symfony demo, etc.)
   💡 **HINT:** This validates Docker + framework + dependencies are correctly installed
6. **Run `make hello-doh`** → Creates framework structures + AI generates hello world files
   💡 **HINT:** Must use framework CLI tools (make:controller, startapp, generate, etc.) then AI code generation
7. **Test hello-doh console** → CLI command showing DOH_HELLOWORLD → If fails: analyze error, debug, retry
   💡 **HINT:** Logs console dans `./var/log/app/django.log` ou framework équivalent
8. **Test hello-doh web** → `/hello` endpoint showing DOH_HELLOWORLD → If fails: analyze error, debug, retry  
   💡 **HINT:** Check routing Traefik + certificats SSL + firewall ports 80/443
9. **Test Hello-DB** (if database) → If fails: analyze error, debug, retry
   💡 **HINT:** Connection string + user/password + database existence + network Docker
10. **Test Hello-Workers** (if workers) → supervisorctl status, worker health checks
    💡 **HINT:** Process status + queue connectivity + worker logs dans `./var/log/supervisor/`
11. **Final Status + Recovery Options:**
    - **Interactive:** Ask user for help if 3 attempts fail + suggest manual fixes
    - **Non-Interactive:** Abort with detailed error file → `./DOH_DEBUG_REPORT.md`
    💡 **HINT ESCALATION:** If 3 failures → generate minimal template + detailed debug guide

### 2. Development Environment Testing

**Single Command Validation:**
```bash
make hello-doh
# → Runs comprehensive stack validation:
#   ✅ Creates framework structures (make:controller, startapp, generate, etc.)
#   ✅ AI generates hello world web + CLI code with DOH_HELLOWORLD validation
#   ✅ Tests console command showing DOH_HELLOWORLD value
#   ✅ Tests web endpoint (/hello) showing DOH_HELLOWORLD value
#   ✅ Tests Hello-DB (database connectivity)
#   ✅ Tests Hello-Workers (supervisord process status)
#   ✅ Checks linter container
#   ✅ Displays all service URLs

# Legacy compatibility (redirects to hello-doh):
make hello-world  # → Same as hello-doh
```

**Supervisord Group Integration Benefits:**
- **Single Container:** Web + workers + schedulers in one place
- **Unified Access:** `make sh` enters container with all processes
- **Process Groups:** Separate web and workers groups for granular control
- **Makefile Commands:** `make restart-web`, `make restart-workers`, `make status`
- **Log Management:** `make logs-web`, `make logs-workers` for targeted debugging
- **Development Workflow:** Restart web without killing long-running workers
- **Debugging Flexibility:** `make worker-debug` for manual debugging, `make worker-shell` for isolated sessions
- **Development Simplicity:** No multiple app containers cluttering namespace

**Conflict Handling:**
- **Interactive Mode:** 
  - Existing docker-compose.yml → **STOP** and ask user: backup/override/merge/abort
  - Ambiguous choices → Present brainstormed stack for confirmation and **WAIT**
  - Multiple framework options → Ask user preference and **WAIT FOR RESPONSE**
  - **NEVER overwrite** without explicit permission
  
- **Non-Interactive Mode:**
  - Existing files → Abort with explanation file (./DOH_CONFLICT_REPORT.md)
  - Missing specifications → Abort with requirements file (./DOH_REQUIREMENTS.md)
  - No internet access → Abort with offline instructions

**🚨 IMPLEMENTATION ENFORCEMENT:**
```text
WRONG: Show config → Continue immediately → Generate files
RIGHT: Show config → WAIT for user input → Process response → Then continue
```

### 3. Installation Documentation avec Debug Guide (INITDEV.md)

**CRITICAL:** After successful stack creation, generate `./INITDEV.md` with complete installation recap + debug hints:

**Template Structure:**
```markdown
# {{PROJECT_NAME}} Development Environment

Generated by DOH `/doh:init-dev` on {{DATE}}

## Stack Configuration

**Technology Stack:**
- Framework: {{FRAMEWORK}} {{VERSION}}
- Database: {{DATABASE}} {{VERSION}}  
- Frontend: {{FRONTEND_FRAMEWORK}} (if detected)
- Testing: {{TEST_FRAMEWORK}}
- Linting: {{LINTERS_LIST}}

**AI Decision Rationale:**
- {{FRAMEWORK}} → {{DATABASE}} (statistical pairing / user specification)
- Version {{VERSION}} (latest stable from {{SOURCE}})
- {{LINTING_TOOLS}} ({{FRAMEWORK}} ecosystem standard)
- {{TEST_FRAMEWORK}} (community preference over alternatives)

## Files Created

**Core Configuration:**
- `./docker-compose.yml` - Main orchestration at project root with {{SERVICES_COUNT}} services
- `./docker/Dockerfile` - {{FRAMEWORK}} {{VERSION}} with supervisord
- `./docker/Makefile` - Development commands with {{FRAMEWORK}}-specific targets

**Environment & Dependencies:**
- `./.env` - Development environment ({{VARIABLES_COUNT}} variables)  
- `./.env.test` - Test environment with {{TEST_DB}} and sync queues
- `./{{DEPENDENCY_FILE}}` - {{FRAMEWORK}} dependencies ({{PACKAGES_COUNT}} packages)

**Frontend Integration:** (if applicable)
- `./{{BUILD_CONFIG}}` - {{BUILD_TOOL}} with {{FRAMEWORK}}-specific dotenv cascade:
  {{DOTENV_CASCADE_DESCRIPTION}}

**Hello World Implementation:**
- `./src/Command/HelloWorldCommand.php` - Symfony Console Command (if Symfony)
- `./app/Console/Commands/DohHelloWorld.php` - Laravel Artisan Command (if Laravel)
- `./myapp/management/commands/doh_hello_world.py` - Django Management Command (if Django)
- `./lib/tasks/doh.rake` - Rails Rake Task (if Rails)
- `./package.json` scripts section - Node.js npm scripts (if Node.js)
- Backend Hello World: {{BACKEND_ENDPOINT}}
- Frontend Hello World: {{FRONTEND_ENDPOINT}} (if applicable)
- **DOH_SECRET Generation:** `date +%s | md5sum | cut -d' ' -f1` (unique per environment)
- **Frontend Dotenv Validation:** DOH_SECRET exposed via VITE_DOH_SECRET/REACT_APP_DOH_SECRET validates build-time env injection

## Quick Start

1. **Setup SSL certificates:**
   ```bash
   mkcert -install
   mkcert "*.{{PROJECT_NAME}}.localhost"
   cp _wildcard.{{PROJECT_NAME}}.localhost* ./docker/certs/
   ```

2. **Start development:**
   ```bash
   cd ./docker
   make dev-setup  # Install dependencies
   make dev       # Start all services
   ```

3. **Validate installation:**
   ```bash
   make hello-world  # Test all components
   ```

## Service URLs

- 📱 **Application:** https://app.{{PROJECT_NAME}}.localhost
- 🗄️ **Database Admin:** https://{{DB_ADMIN}}.{{PROJECT_NAME}}.localhost
- 📧 **Mail Testing:** https://mailhog.{{PROJECT_NAME}}.localhost  
- 🔧 **Traefik Dashboard:** http://localhost:8080

## Development Commands

**Container Management:**
- `make dev` - Start development environment
- `make sh` - Enter main application container
- `make down` - Stop all services

**{{FRAMEWORK}}-Specific Commands:**
{{FRAMEWORK_COMMANDS_LIST}}

**Process Management:** (supervisord groups)
- `make status` - Show all process status
- `make restart-web` - Restart web server processes
- `make restart-workers` - Restart background worker processes
- `make logs-web` - Show web server logs
- `make logs-workers` - Show worker process logs

**Testing:**
- `make test` - Run {{TEST_FRAMEWORK}} tests ({{TEST_ENV_VAR}}={{TEST_ENV_VALUE}})
- `make test-coverage` - Generate coverage report in ./var/coverage/

**Code Quality:**
- `make lint-check` - Run linting checks ({{LINTERS_LIST}})
- `make lint-autofix` - Auto-fix linting issues

## Directory Structure

```
Project Root:
├── docker-compose.yml       # Service orchestration (ALWAYS at root)
├── docker-compose.env       # Environment config (ALWAYS at root)  
├── Makefile                # Development commands (at root)
├── .env                    # Development environment
├── .env.test               # Test environment
├── {{DEPENDENCY_FILE}}     # {{FRAMEWORK}} dependencies
├── ./docker/               # Container configurations
│   ├── app/
│   │   ├── Dockerfile      # {{FRAMEWORK}} {{VERSION}} + supervisord
│   │   └── supervisord.conf # Process management (web + workers)
│   ├── linter/
│   │   └── Dockerfile      # Linting tools
│   └── traefik/
│       ├── traefik.yml     # Reverse proxy config
│       └── certs/          # SSL certificates (gitignored)
├── ./src/                  # Application source
│   ├── hello_world.{{EXT}} # Hello World implementations
│   └── ...
└── ./var/                  # Runtime data (gitignored)  
    ├── data/               # Database persistence
    ├── log/                # Application logs
    ├── coverage/           # Test coverage reports
    └── storage/            # File uploads, cache, sessions  
.env.example                # Environment documentation
```

## Framework-Specific Patterns

**{{FRAMEWORK}} Dotenv Cascade:** (replicated in frontend)
{{DETAILED_DOTENV_CASCADE}}

**Testing Strategy:**
- **Environment Injection:** `{{TEST_ENV_VAR}}={{TEST_ENV_VALUE}}` → Container
- **Dotenv Routing:** Application routes to `.env.test` configuration
- **Database:** {{TEST_DATABASE_DESCRIPTION}}
- **Workers:** {{TEST_WORKER_DESCRIPTION}}

**Worker Architecture:** (if applicable)
- **Web Processes:** {{WEB_PROCESSES_DESCRIPTION}}
- **Worker Processes:** {{WORKER_PROCESSES_DESCRIPTION}}  
- **Single Container:** Unified via supervisord (no namespace pollution)

## Validation Results

✅ **Console Hello World:** {{CONSOLE_RESULT}}
✅ **Web Hello World:** {{WEB_RESULT}}  
✅ **Database Connectivity:** {{DB_RESULT}}
✅ **Worker Processes:** {{WORKER_RESULT}} (if applicable)
✅ **Frontend Integration:** {{FRONTEND_RESULT}} (if applicable)
✅ **Linter Container:** {{LINTER_RESULT}}

## Troubleshooting

**Issues → Solutions:**
- Permissions → `export UID && export GID=$(id -g)`
- SSL → `mkcert -install` then `make ssl-setup`
- Database → Check DATABASE_URL + `./var/log/[mysql|postgres]/`
- Workers → `supervisorctl status/restart workers:*`
- Logs → `./var/log/*/` | `make logs` | `make sh`
- Debug → `$(DOCKER_COMPOSE) ps` | `supervisorctl status`

---
*Generated by DOH init-dev on {{TIMESTAMP}}*
*Framework: {{FRAMEWORK}} {{VERSION}} | Database: {{DATABASE}} {{VERSION}}*
```

### 4. Final Synthesis Report

```text
🎉 DOH Development Stack Created Successfully

Stack: {{FRAMEWORK}} {{VERSION}} + {{DATABASE}} + {{LINTERS}}
URLs: https://app.{{project}}.localhost | Traefik: :8080

✅ Validation: Console + Web + DB + Workers + Linters

Next: make dev → make hello-world → make sh → Start coding!
💡 Debug: export UID/GID → make logs → check INITDEV.md
```

**Directory Flexibility:**
```bash
# User can specify any directory structure
/doh:init-dev "Django with PostgreSQL in ./infra"  → creates in ./infra/
/doh:init-dev "Node.js in ./containers"           → creates in ./containers/
/doh:init-dev --detect                           → uses ./docker-dev/ (default)
```

## Key Features

**Templates:** Modular | Current versions | Flexible composition | API fallbacks
**Linters:** Separate containers | Version isolation | Profile-based | Customizable
**Multi-Project:** Domain isolation | SSL certificates | Configurable ports | Namespacing
**Developer UX:** One-command setup | Comprehensive Makefile | Quick start guide | Extension points

**Debug Philosophy:** Automatic hints | Centralized logs | Debug commands | Troubleshooting docs | Guided escalation

💡 **Meta:** This guide evolves - contribute improvements to `.claude/commands/doh/init-dev.md`