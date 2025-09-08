---
allowed-tools: Bash, Glob, Grep, LS, Read, Write, Edit, MultiEdit, WebFetch
---

# Initialize Development Stack - AI-Driven Stack Creation

Creates a modern, pragmatic development environment by analyzing requested stack and cherry-picking from DOH templates. Uses web research to discover current best practices for the specific stack and translates them into DOH-compliant Docker setup.

## Usage
```
/doh:init-dev <natural language stack description>
/doh:init-dev "Python Django with PostgreSQL in ./docker directory"  
/doh:init-dev "Node.js React fullstack with MySQL and Redis"
/doh:init-dev "PHP Laravel API with PostgreSQL and background jobs"
/doh:init-dev "Python FastAPI microservice with MongoDB"
```

## AI-Driven Approach

This command is **AI-piloted**, not scripted, because each stack has unique requirements and evolving best practices:

### 1. Stack Analysis (Detection vs Manual)

**Manual Mode** (`/doh:init-dev "Python Django..."`):
- Parse natural language description  
- Identify components from user input

**Detection Mode** (`/doh:init-dev --detect`):
- **File Analysis:** Examine existing project files for technology indicators
  ```text
  package.json → Node.js/JavaScript stack
  requirements.txt → Python stack  
  composer.json → PHP stack
  Cargo.toml → Rust stack
  go.mod → Go stack
  ```
- **Dependency Analysis:** Parse dependency files for framework detection
  ```text
  Django in requirements.txt → Django framework
  express in package.json → Express.js framework
  laravel/framework in composer.json → Laravel framework
  ```
- **README Analysis:** Extract technology mentions and setup instructions
- **Existing Docker Analysis:** Check current docker-compose.yml for services
- **Database Detection:** Look for database connection configs and migrations

### 2. Cherry-Pick from Templates
- Analyze `.claude/templates/init-dev/` for relevant inspiration
- Select appropriate base templates (common/, stacks/, services/)
- Adapt template patterns to detected/requested stack

### 3. Research Current Best Practices (Tech-Adaptive)
- **Mode Interactif:** WebSearch with tech-specific sources for latest recommendations
- **Mode Non-Interactif:** Use explicitly specified versions and tools only
- **Tech-Specific Sources:** Adapt research to technology ecosystem

**Source Selection by Technology:**
```text
PHP → WebSearch "PHP 8.3 latest site:php.net" + Docker Hub php:8.3-fpm
Python → WebSearch "Python 3.12 site:python.org" + PyPI trends + Docker Hub python:3.12-slim  
Node.js → WebSearch "Node.js LTS site:nodejs.org" + npm registry + Docker Hub node:18-alpine
Java → WebSearch "OpenJDK latest site:openjdk.org" + Maven Central + Docker Hub openjdk:21
.NET → WebSearch "dotnet latest site:dotnet.microsoft.com" + NuGet + Docker Hub mcr.microsoft.com/dotnet
Go → WebSearch "Go latest site:golang.org" + pkg.go.dev + Docker Hub golang:1.21-alpine
Rust → WebSearch "Rust stable site:rust-lang.org" + crates.io + Docker Hub rust:1.72
C++ → WebSearch "GCC latest" + vcpkg/Conan + Docker Hub gcc:latest
Ruby → WebSearch "Ruby stable site:ruby-lang.org" + rubygems.org + Docker Hub ruby:3.2
```

**Framework-Specific Research:**
```text  
Laravel → WebSearch "Laravel requirements site:laravel.com" + Packagist trends + Queue workers detection
         + "Laravel testing best practices APP_ENV" + "Laravel Mix dotenv frontend"
Django → WebSearch "Django LTS site:djangoproject.com" + PyPI analysis + Celery workers detection
         + "Django testing pytest settings" + "Django webpack dotenv integration"
Rails → WebSearch "Rails current site:rubyonrails.org" + RubyGems trends + Sidekiq workers detection
        + "Rails test environment configuration" + "Rails webpacker dotenv"
Spring Boot → WebSearch "Spring Boot latest site:spring.io" + Maven Central + async processing detection
              + "Spring Boot test profiles" + "Spring Boot frontend environment variables"
Express → WebSearch "Express.js best practices" + npm registry trends + worker processes detection
          + "Node.js testing with dotenv" + "webpack dotenv plugin configuration"
```

**Testing Patterns Research:**
```text
WebSearch "{{framework}} test environment isolation best practices"
WebSearch "{{framework}} test database configuration in-memory"
WebSearch "{{framework}} dotenv test environment setup"
WebSearch "{{framework}} coverage reports configuration"
```

**Frontend Dotenv Integration Research:**
```text
WebSearch "webpack dotenv plugin {{framework}}"
WebSearch "vite environment variables {{framework}}"
WebSearch "{{framework}} frontend backend environment sync"
WebSearch "process.env frontend build {{framework}}"
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
.env                    # Development: FRONTEND_API_URL=http://localhost:8000
.env.test              # Testing: DATABASE_URL=sqlite:///var/test.db, QUEUE_DRIVER=sync
.env.example           # Documentation: All variables with example values

# Framework-specific frontend variable mapping:
React:     REACT_APP_API_URL=${FRONTEND_API_URL}     # Exposed to window.process.env
Vue:       VUE_APP_API_URL=${FRONTEND_API_URL}       # Exposed to process.env
Vite:      VITE_API_URL=${FRONTEND_API_URL}          # Exposed to import.meta.env
Next.js:   NEXT_PUBLIC_API_URL=${FRONTEND_API_URL}   # Exposed to process.env
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

**AI Research Pattern:** 
```text
WebSearch "{{framework}} dotenv environment precedence order"
WebSearch "{{framework}} .env file loading cascade hierarchy"
WebSearch "{{framework}} production environment configuration"
WebSearch "{{framework}} docker development setup requirements"
WebSearch "{{framework}} required system tools dependencies"
```

**Framework-Specific Tool Requirements (AI-Detected):**
```text
PHP/Laravel/Symfony → composer, git, unzip (for composer dependencies)
Node.js/Express/Nest → npm/yarn, git, python3 (for native modules compilation)
Python/Django/FastAPI → pip, git, build-essential, python3-dev (for compiled dependencies)  
Ruby/Rails → bundler, git, build-essential, ruby-dev (for native gems)
Go → git, ca-certificates (for module dependencies)
Java/Spring → maven/gradle, git, openjdk (framework-specific)
.NET → dotnet CLI, git (for NuGet packages)
```

**Framework Tool Cascade Installation (AI-Adaptive):**

**Multi-Stage Pattern for Tool Cherry-Picking:**
```dockerfile
# AI détecte stack → génère stages appropriés
FROM node:20 AS node-tools         # Si frontend détecté  
FROM composer:2 AS composer-tools   # Si PHP détecté
FROM python:3.12 AS python-tools    # Si Python détecté

FROM php:8.3-fpm  # PHP final image par défaut

# Cherry-pick Node.js tools (AI-conditionnel)
COPY --from=node-tools /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-tools /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Cherry-pick Composer (AI-conditionnel)
COPY --from=composer-tools /usr/bin/composer /usr/bin/composer

# Système dependencies (AI-détectées)
RUN apt-get update && apt-get install -y git sudo supervisor unzip
```

**AI Stack Detection → Base Image Strategy:**
```text
Laravel/Symfony + frontend → FROM composer:2 + FROM node:20 → php:8.3-fpm
Laravel/Symfony seul → FROM composer:2 → php:8.3-fpm
Django + React → FROM python:3.12 + FROM node:20 → python:3.12-slim
Django seul → FROM python:3.12-slim
Rails + Webpack → FROM ruby:3.2 + FROM node:20 → ruby:3.2-slim
Node.js pur → FROM node:20-alpine (pas de multi-stage)

Règle PHP: Toujours php:X.X-fpm comme image finale (simplicité)
```

**Tool Installation Strategy (Non-Template):**
- **AI Research:** WebSearch "{{framework}} docker development requirements"
- **Conditional Stages:** Créer stages seulement pour outils détectés
- **Cherry-Pick Pattern:** COPY --from= pour éviter bloat des base images  
- **Version Detection:** Utiliser versions officielles actuelles des images
- **System Tools:** git, supervisor, sudo installés dans main stage

**Worker/Daemon Detection & Integration:**
- **Single Container Philosophy:** Web server + workers + daemons in one container via supervisord
- **Alternative Avoided:** Multiple app containers (pollutes namespace, complicates dev workflow)
- **Supervisord Benefits:** Process management, log aggregation, unified container access via `make sh`

### 4. Translate to DOH Patterns
- Apply DOH principles (Docker + Traefik + mkcert + Hello World)
- Ensure zero permission issues (UID/GID matching)
- Create project-specific service selection
- Generate working Hello World for validation

### Directory Customization
- User can specify directory: "in ./docker" → creates files in `./docker/`
- Default: `./docker-dev/` (DOH standard)
- Respects user preference while maintaining DOH patterns

## Core Philosophy

### Docker-Focused & Pragmatic
- **Docker as standard** unless explicitly contraindicated
- **Realistic containers** - avoid over-containerization
- **Multi-project friendly** - `{service}.{project}.local` domains
- **Linting containers** - Separate linter containers to avoid version conflicts

### Template-Based Generation
- Uses templates from `.claude/templates/init-dev/`
- **Templates are illustrations** - versions and configs adapted at runtime
- Fetches current versions from official APIs
- Modular template system for stacks and services

## Implementation Workflow

### 1. Analyze Request & Research Stack

**Natural Language Processing:**
```text
Input: "Python Django with PostgreSQL in ./docker directory"
→ Stack: Python + Django  
→ Database: PostgreSQL
→ Directory: ./docker/
→ Inferred needs: Web framework + ORM + Database + Testing + Linting
```

**AI-Driven Research (Tech-Adaptive Sources):**
- WebSearch: "Django 2024 best practices development setup site:djangoproject.com"
- WebSearch: "Python Django recommended linters 2024" + PyPI trends analysis
- WebSearch: "Django testing tools pytest vs unittest" 
- Tech-specific version detection: python.org + PyPI + Docker Hub python:x.x-slim

**Template Cherry-Picking:**
- Select from `.claude/templates/init-dev/stacks/python/`
- Check `.claude/templates/init-dev/services/postgres.yml`
- Adapt `.claude/templates/init-dev/common/Makefile` for Django-specific commands

### 2. Generate Stack-Specific Configuration

**AI Decision Making:**
- Based on research, select optimal linters: `black`, `flake8`, `mypy`, `isort`
- Choose testing framework: `pytest` (most popular in 2024)
- Determine Django version compatibility with Python version
- Select appropriate database client and ORM migrations strategy
- **Create Framework-Native Console Commands:**
  - Symfony → `src/Command/HelloWorldCommand.php` using Symfony Console Component
  - Laravel → `app/Console/Commands/DohHelloWorld.php` using Artisan
  - Django → `management/commands/doh_hello_world.py` using Django Management
  - Rails → `lib/tasks/doh.rake` using Rake tasks
  - Node.js → `package.json` scripts + `scripts/doh-hello-world.js`

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

**Essential Components (Always):**
- ✅ Docker Compose with Traefik routing
- ✅ SSL certificates via mkcert 
- ✅ UID/GID permission matching
- ✅ Multi-project domain pattern: `app.{project}.local`
- ✅ Makefile with `dev`, `sh`, `hello-world` targets
- ✅ Working Hello World endpoint + console command

**Stack-Specific Components:**
- ✅ Linter container with discovered best-practice tools
- ✅ Testing framework setup with sample test
- ✅ Framework-specific dependencies (requirements.txt, package.json, etc.)
- ✅ Database service with persistent volumes
- ✅ Dotenv configuration with security practices
- ✅ **Hello World Console Command** - CLI validation tool
- ✅ **Hello World Web Endpoint** - HTTP server validation
- ✅ **Supervisord Integration** - Single container for web + workers + daemons

**Directory Structure Created:**
```
./docker/                    # User-specified directory
├── docker-compose.yml       # Main orchestration
├── docker-compose.env-docker # Template config 
├── traefik.yml-docker       # Traefik config template
├── dynamic.yaml-docker      # TLS config template
├── Makefile                 # Development commands
├── certs/                   # SSL certificates (gitignored)
├── data/                    # Database persistence (gitignored)  
├── logs/                    # Application logs (gitignored)
└── scripts/
    └── install-deps.sh      # Dependency installer
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

4. **File Generation Process (with Worker Support):**
   ```text
   AI Creates:
   • ./docker/docker-compose.yml → Django + PostgreSQL + Linter services (single app container)
   • ./docker/docker-compose.env-docker → Project config with APP_CONTAINER variable
   • ./docker/Dockerfile → Python 3.12-slim with Django + supervisord
   • ./docker/Dockerfile.linter → Separate container with black/flake8/mypy/isort
   • ./docker/supervisord.conf → Web server + Celery workers configuration
   • ./docker/Makefile → Enhanced with Django + worker commands + hello-world target
   • ./requirements.txt → Django 5.0 + psycopg2 + celery + pytest-django + linters
   • ./docker/traefik.yml-docker → HTTPS routing configuration
   • ./src/hello_world.py → Django Hello World view + management command
   • ./manage.py hello → Console Hello World command + Celery status check
   • ./INSTADEV.md → Quick start guide with isolated test environment
   • ./.env.test → Test configuration (SQLite, in-memory cache, sync queues)
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
   
   ✅ Proceed with this configuration? (y/N)
   ```

## Command Options

### Interactive Mode (Default)
```bash
/doh:init-dev "Python Django with PostgreSQL in ./docker directory"
# → Shows brainstormed configuration and waits for user confirmation
```

### Non-Interactive Mode (For Agents)
```bash
/doh:init-dev --non-interactive "Python Django with PostgreSQL in ./docker directory"
# → Proceeds immediately without confirmation prompts
# → Perfect for automated workflows and agent execution
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

**Not Scriptable Because:**
- Stack-specific best practices evolve rapidly
- Linting tools and versions change frequently  
- Framework-specific patterns vary significantly
- User preferences (directory structure, tooling) need flexibility
- Current industry trends require real-time research
- **Each technology has different official sources** (php.net, python.org, nodejs.org, etc.)

**Mode-Specific Behavior:**
- **Interactive Mode:** WebSearch + user confirmation for ambiguities
- **Non-Interactive Mode:** Explicit specifications required, abort with explanation if unclear

**AI Advantages:**
- 🔍 Real-time web research for current best practices
- 🧠 Context-aware decision making based on stack analysis
- 🎯 Intelligent template cherry-picking and adaptation
- 💡 Dynamic version detection and compatibility checking
- 🛠️ Custom Makefile generation with stack-appropriate commands
- ✅ **Self-validation via Hello World testing** - never declares success until working

## Testing Strategy - Isolated Test Environment

### Environment Variable Injection Pattern
**The stack templates follow DOH testing principles:**

1. **Container Level** - Inject test environment variable to app container
2. **Dotenv Level** - Application dotenv system handles environment routing  
3. **Makefile Level** - Provide convenient test commands with proper env vars

**Stack-Specific Test Variables:**
```bash
Laravel:        APP_ENV=testing          # Routes to .env.testing
Symfony:        APP_ENV=test             # Routes to .env.test  
Django/Python:  DJANGO_SETTINGS_MODULE  # Routes to settings.test
Rails/Ruby:     RAILS_ENV=test           # Routes to test environment  
Node.js:        NODE_ENV=test            # Routes to test config
```

**Generated Files:**
- **`.env.test`** template with test-optimized configuration
- **Makefile** test commands with environment injection
- **Test isolation** via in-memory/SQLite databases
- **Coverage reports** in `./var/coverage/`

## Final Output & Testing

### 1. Hello World Implementation (AI Success Criteria)

**🎯 CRITICAL: Stack creation is NOT complete until ALL Hello Worlds work!**

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
```

**Web Endpoint (HTTP validation):**
```bash
# Test backend web hello world endpoint (priority)
curl -k https://app.{project}.localhost/hello
# Expected: {"message": "Hello from Django on DOH!", "timestamp": "..."}

# Frontend Hello World (if applicable)
curl -k https://app.{project}.localhost/
# Expected: React/Vue app with "Hello DOH!" message
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
- **Separate shells:** `docker compose run` for isolated debugging sessions
- **Inspector tools:** Real-time task and worker monitoring

**AI Self-Validation Process (3 attempts max):**
1. **Generate stack files** (including supervisord.conf if workers detected)
2. **Run `make dev`** 
3. **Test console Hello World** → If fails: analyze error, debug, retry
4. **Test web Hello World** → If fails: analyze error, debug, retry  
5. **Test Hello-DB** (if database) → If fails: analyze error, debug, retry
6. **Test Hello-Workers** (if workers) → supervisorctl status, worker health checks
7. **Final Status:**
   - **Interactive:** Ask user for help if 3 attempts fail
   - **Non-Interactive:** Abort with detailed error file

### 2. Development Environment Testing

**Single Command Validation:**
```bash
make hello-world
# → Runs comprehensive stack validation:
#   ✅ Starts all services
#   ✅ Tests console command (backend priority)
#   ✅ Tests web endpoint (backend + frontend if present)
#   ✅ Tests Hello-DB (database connectivity)
#   ✅ Tests Hello-Workers (supervisord process status)
#   ✅ Checks linter container
#   ✅ Displays all service URLs
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
  - Existing docker-compose.yml → Ask user: backup/override/merge/abort
  - Ambiguous choices → Present brainstormed stack for confirmation
  - Multiple framework options → Ask user preference
  
- **Non-Interactive Mode:**
  - Existing files → Abort with explanation file (./DOH_CONFLICT_REPORT.md)
  - Missing specifications → Abort with requirements file (./DOH_REQUIREMENTS.md)
  - No internet access → Abort with offline instructions

### 3. Installation Documentation (INITDEV.md)

**CRITICAL:** After successful stack creation, generate `./INITDEV.md` with complete installation recap:

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
- `./docker/docker-compose.yml` - Main orchestration with {{SERVICES_COUNT}} services
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
./docker/                    # Development environment
├── docker-compose.yml       # Service orchestration
├── Dockerfile              # {{FRAMEWORK}} {{VERSION}} + supervisord  
├── supervisord.conf         # Process management (web + workers groups)
├── Makefile                # Development commands
├── certs/                  # SSL certificates (gitignored)
├── data/                   # Database persistence (gitignored)
└── logs/                   # Application logs (gitignored)

./src/                      # Application source
├── hello_world.{{EXT}}     # Hello World implementations
└── ...

./var/                      # Runtime data (gitignored)  
├── log/                    # Application logs
├── coverage/               # Test coverage reports
└── storage/                # File uploads, cache, sessions

{{DEPENDENCY_FILE}}         # {{FRAMEWORK}} dependencies
.env                        # Development environment
.env.test                   # Test environment  
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

**Permission Issues:**
- Check UID/GID mapping in docker-compose.yml
- Ensure ./var/ directories are writable

**SSL Certificate Issues:**
- Run `mkcert -install` first
- Copy certificates to ./docker/certs/

**Database Connection Issues:**  
- Check DATABASE_URL in .env
- Ensure database container is running: `docker compose ps`

**Worker Process Issues:**
- Check supervisord status: `make sh` then `supervisorctl status`
- Debug single worker: `make worker-debug`
- Check worker logs: `make logs-workers`

---
*Generated by DOH init-dev on {{TIMESTAMP}}*
*Framework: {{FRAMEWORK}} {{VERSION}} | Database: {{DATABASE}} {{VERSION}}*
```

### 4. Final Synthesis Report

**After successful creation, display:**
```text
🎉 DOH Development Stack Created Successfully
============================================

📋 **Stack Summary:**
• Technology: Python Django 5.0 + PostgreSQL 16
• Linting: black + flake8 + mypy + isort (in separate container)
• Testing: pytest + pytest-django
• SSL: HTTPS with mkcert certificates
• Domain: https://app.{project}.localhost

📁 **Files Created:**
• ./docker/docker-compose.yml - Main orchestration
• ./docker/Dockerfile + Dockerfile.linter - App + linting containers  
• ./docker/Makefile - Enhanced development commands
• ./requirements.txt - Python dependencies
• ./src/hello_world.py - Hello World implementations
• ./INSTADEV.md - Quick start guide

🚀 **Quick Validation:**
make hello-world
# → Tests everything and displays service URLs

🌐 **Service URLs:**
• 📱 App: https://app.{project}.localhost
• 🗄️ Database: https://adminer.{project}.localhost  
• 📧 Mail: https://mailhog.{project}.localhost
• 🔧 Traefik: http://localhost:8080

⚡ **Validation Status:**
✅ Console Hello World: WORKING
✅ Web Hello World: WORKING  
✅ Stack creation: COMPLETE

📝 **Next Steps:**
1. make dev          # Start development environment
2. make hello-world  # Validate everything works
3. make sh          # Enter main app container  
4. Start coding! 🚀

⚠️ **Validation Results:**
✅ Console Hello World: WORKING (Django management command)
✅ Web Hello World: WORKING (HTTP endpoint + React frontend)  
✅ Hello-DB: WORKING (PostgreSQL connectivity confirmed)
✅ Hello-Workers: WORKING (gunicorn + celery worker + celery beat via supervisord)
✅ Linter Container: WORKING (black, flake8, mypy, isort)

📋 **AI Decision Rationale:**
• Django → PostgreSQL (statistical pairing)
• Python 3.12 (latest stable from python.org)
• Django 5.0.x (LTS from djangoproject.com) 
• black+flake8+mypy (Python ecosystem standard)
• pytest-django (community preference)

🔧 **Tech-Specific Sources Used:**
• Python versions: python.org + Docker Hub python:3.12-slim
• Django versions: djangoproject.com/download/
• Package trends: PyPI analysis + GitHub stars
• Database choice: Statistical Python→PostgreSQL pairing
```

**Directory Flexibility:**
```bash
# User can specify any directory structure
/doh:init-dev "Django with PostgreSQL in ./infra"  → creates in ./infra/
/doh:init-dev "Node.js in ./containers"           → creates in ./containers/
/doh:init-dev --detect                           → uses ./docker-dev/ (default)
```

## Key Features

### Template-Based & Up-to-Date
- **Modular templates** from `.claude/templates/init-dev/`
- **Current versions** fetched from official APIs at runtime
- **Flexible composition** of services and stacks

### Linter Integration  
- **Separate containers** for linting tools per stack
- **Version isolation** - no conflicts with main application
- **Team standardization** - same tools for everyone
- **Profiles support** - start linters only when needed

### Multi-Project Support
- **Domain isolation** via `{service}.{project}.local`
- **SSL certificates** with mkcert wildcards
- **No port conflicts** - everything through Traefik
- **Project namespacing** in all configurations

### Developer Experience
- **One command setup** - `make dev-setup && make dev`
- **Comprehensive Makefile** with linting, database, and dev commands
- **Quick start guide** - INSTADEV.md with stack-specific examples
- **Template documentation** - clear extension points

This refactored approach makes the command much more maintainable and extensible while keeping the core logic focused on orchestration rather than template content.