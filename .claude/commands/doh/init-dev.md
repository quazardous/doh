---
allowed-tools: Bash, Glob, Grep, LS, Read, Write, Edit, MultiEdit, WebFetch
---

# /doh:init-dev - DOH Kitchen System

The DOH Kitchen is an AI-assisted template processing system that transforms natural language descriptions into complete Docker development environments through systematic template composition and intelligent configuration.

## Overview

**Core Concept:** The "Kitchen" - A systematic template processing pipeline that combines, configures, and customizes development environment components based on detected or specified technology stacks.

**Philosophy:** Template composition + AI detection + placeholder substitution + validation testing = Production-ready development environment

## Kitchen Process - The Core Workflow

The DOH Kitchen follows a systematic 6-phase template processing approach:

### Phase 1: Stack Analysis & Detection
1. **Analyze natural language request** or **detect existing project** (see [DETECT.md](.claude/templates/init-dev/DETECT.md))
2. **Identify framework, database, frontend** using framework detection patterns

### Phase 2: Template Foundation Loading  
3. **Load core templates** from `.claude/templates/init-dev/core/`
4. **Read AI-Kitchen instructions** from template-specific ai-kitchen.md files in stacks/
5. **Establish base patterns** common to all stacks (Makefile.seed, docker-compose-base, etc.)

### Phase 3: Template Discovery & Selection
6. **Discover technology-specific templates** by exploring `.claude/templates/init-dev/stacks/` structure
7. **Scan for ai-kitchen.md files** in selected template directories for template-specific instructions
8. **Map @AI-Kitchen instructions** from template-specific ai-kitchen.md files for processing

### Phase 4: Template Processing & File Generation
9. **Process @AI-Kitchen tags** - SUBSTITUTE/CONDITIONAL/MERGE/GENERATE instructions
10. **Replace all placeholders** using [PLACEHOLDERS.md](.claude/templates/init-dev/PLACEHOLDERS.md) system  
11. **Generate configuration files** with working defaults (-docker suffix)
12. **Create main Makefile** by merging Makefile.seed + framework-specific additions

### Phase 5: Container Setup & Launch
13. **Build Docker images** with proper multi-stage approach and UID/GID handling
14. **Generate SSL certificates** via mkcert for local development
15. **Launch development services** using generated docker-compose configuration

### Phase 6: Stack Validation & Testing
16. **Container connectivity test** - Phase 0 validation (basic container access)
17. **Framework native hello world** - Phase 1 validation (framework functionality)
18. **DOH hello world validation** - Phase 2 validation (complete stack verification)

See [HELLOWORLD.md](.claude/templates/init-dev/HELLOWORLD.md) for complete three-phase validation methodology.

## Kitchen Template System Architecture

### Template Organization Structure
```
.claude/templates/init-dev/
├── core/                           # Foundation templates (all stacks)
│   ├── Makefile.seed              # Base Makefile foundation
│   ├── docker-compose-base.yml    # Base service definitions
│   └── scripts/                   # Common setup scripts
├── common/                        # Shared components
│   ├── traefik/                   # Reverse proxy templates
│   ├── env.template               # Environment configuration
│   └── gitignore.template         # Version control patterns
├── stacks/                        # Stack-specific templates
│   ├── python/                    # Python-based stacks
│   ├── php/                       # PHP-based stacks
│   └── node/                      # Node.js-based stacks
└── services/                      # Service-specific templates
    ├── postgresql/                # PostgreSQL configuration
    ├── mariadb/                   # MariaDB configuration
    └── redis/                     # Redis configuration
```

### @AI-Kitchen Instruction System
Templates contain special processing instructions that guide the Kitchen:

- **@AI-Kitchen: SUBSTITUTE** - Replace {{placeholders}} with real values
- **@AI-Kitchen: CONDITIONAL** - Include/exclude based on detected technology
- **@AI-Kitchen: MERGE** - Combine multiple templates intelligently  
- **@AI-Kitchen: GENERATE** - Create framework-specific content dynamically

### Three-Stage File Processing
1. **Kitchen Templates** - Source templates with {{placeholders}} (e.g., `docker-compose.env-docker` template)
2. **Generated Files** - Kitchen-processed files at project root (e.g., `docker-compose.env-docker`) 
3. **Local Developer Files** - Customizable copies created by `make env-config` (e.g., `docker-compose.env`)

**Special Case:** `Makefile.seed` template is processed by Kitchen directly to create `Makefile` (bypasses stage 3)

This allows developers to modify local configurations while preserving working defaults.

## Kitchen Output Patterns

### Mandatory Generated Structure
```
project-root/
├── docker-compose.yml              # ALWAYS at root - service orchestration
├── docker-compose.env              # ALWAYS at root - environment config
├── Makefile                        # Seed foundation + framework additions
├── .env                           # Development environment variables
├── INITDEV.md                     # Installation & troubleshooting guide
└── {container-directory}/         # User-specified (default: ./docker)
    ├── app/
    │   ├── Dockerfile             # Multi-stage build with detected technologies
    │   └── supervisord.conf       # Process management configuration
    ├── traefik/
    │   ├── traefik.yml           # Reverse proxy configuration
    │   └── certs/                # SSL certificates (generated)
    └── {database}/               # Database-specific configurations
        └── conf.d/               # Custom database settings
```

### Kitchen Environment Configuration Pattern
```bash
# docker-compose.env (generated at root)
PROJECT_NAME=actual-project-name        # Substituted, NOT {{PROJECT_NAME}}

# Container Naming (for multi-branch development)
APP_CONTAINER=actual-project-name-app-1     # Main application container
LINTER_CONTAINER=actual-project-name-linter-1  # Code quality container

# Traefik Ports (modify if conflicts on dev machine)
EXTERNAL_HTTP_PORT=8000                 # Working default
EXTERNAL_HTTPS_PORT=4430                # Working default  
TRAEFIK_DASHBOARD_PORT=8080             # Dashboard port

DOH_HELLOWORLD=f4a7b2c8e9d1a6f3        # Generated validation hash
```

### Kitchen Makefile Composition Pattern
```makefile
# Generated Makefile = Exact Makefile.seed + Framework additions
# ========== FROM Makefile.seed (preserved exactly) ==========
include docker-compose.env
DOCKER_COMPOSE := export UID && export GID=$$(id -g) && docker compose --env-file docker-compose.env
RUN_APP := $(DOCKER_COMPOSE) exec app

dev: env-config
	$(DOCKER_COMPOSE) up -d

env-config:
	@echo "Creating local config files from templates..."
	# Core pattern preserved exactly

# ========== Framework additions (appended after seed) ==========
migrate:  # Django-specific addition
	$(RUN_APP) python manage.py migrate

artisan:  # Laravel-specific addition  
	$(RUN_APP) php artisan $(cmd)
```

## Kitchen Usage & Command Modes

### Basic Kitchen Commands
```bash
/doh:init-dev "Django with PostgreSQL in ./docker"    # Framework + DB + location
/doh:init-dev "Node.js React fullstack with MySQL"    # Full-stack specification
/doh:init-dev "Laravel API with Redis workers"        # API + background jobs
/doh:init-dev --detect                                 # Auto-analyze existing project
```

### Interactive Kitchen Mode (Default)
Shows Kitchen analysis results and **waits for user confirmation**:
```bash
/doh:init-dev "Python Django with PostgreSQL"
# → Kitchen analyzes: Framework=Django, DB=PostgreSQL, defaults applied
# → Shows configuration: ports, versions, components
# → Waits for approval: "Proceed with this configuration? [y/N]"
# → Only proceeds after user confirmation
```

### Non-Interactive Kitchen Mode  
Processes Kitchen templates immediately without user interaction:
```bash
/doh:init-dev --non-interactive "Django API with PostgreSQL"
# → Kitchen processes templates automatically
# → Perfect for automation and CI/CD pipelines
```

### Detection Kitchen Mode
Kitchen analyzes existing codebase and processes appropriate templates:
```bash
/doh:init-dev --detect
# → Kitchen scans: files, dependencies, configurations
# → Detects: framework, versions, patterns (see DETECT.md)
# → Processes matching templates automatically
```

## Kitchen Prerequisites & Setup

### Host Requirements
The Kitchen system requires these tools on the host machine:

- **Docker & Docker Compose** - Container orchestration (see [DOCKER.md](.claude/templates/init-dev/DOCKER.md))
- **mkcert** - SSL certificate generation for local development  
- **make** - Makefile execution for development commands

### Quick Installation
```bash
# Automated installation of all Kitchen prerequisites
.claude/templates/init-dev/core/scripts/install-deps.sh
```

### Manual Installation
See [DOCKER.md](.claude/templates/init-dev/DOCKER.md) for detailed installation instructions by platform.

## Kitchen Validation & Testing

### Three-Phase Kitchen Validation
The Kitchen generates validation tests to ensure stack functionality:

1. **Phase 0 - Container Connectivity**: Basic container access and file system validation
2. **Phase 1 - Framework Native**: Framework's standard hello world functionality  
3. **Phase 2 - DOH Validation**: Complete stack verification with hash validation

```bash
make hello-doh  # Runs complete Kitchen validation suite
```

### Kitchen Success Criteria
✅ All Kitchen-generated containers start without errors  
✅ Framework functionality works as expected  
✅ DOH validation hash verification passes  
✅ Database connectivity established  
✅ SSL certificates functional  
✅ All services accessible via generated URLs

## Kitchen Technology Detection & Pairing

### Framework Detection Process
The Kitchen uses systematic detection (see [DETECT.md](.claude/templates/init-dev/DETECT.md)):
- **File pattern analysis** - manage.py, artisan, package.json detection
- **Dependency analysis** - requirements.txt, composer.json parsing
- **Configuration recognition** - Framework-specific config files
- **Confidence scoring** - Resolution for ambiguous cases

### Kitchen Statistical Pairing Logic
Framework detection drives automatic technology pairing:
- **Django** → PostgreSQL (Python ecosystem preference)
- **Laravel** → MySQL/MariaDB (PHP framework default)  
- **Express** → PostgreSQL (JavaScript ecosystem preference)
- **Rails** → PostgreSQL (Ruby ecosystem preference)

### Kitchen Version Resolution
1. **Existing project** - Preserve detected versions from dependency files
2. **Docker Hub API** - Latest stable versions for new stacks
3. **Kitchen template defaults** - Fallback versions when API unavailable

## Kitchen Troubleshooting & Debug

### Kitchen Debug Commands
```bash
make logs           # View all Kitchen-generated service logs
make sh             # Enter Kitchen-generated app container  
make status         # Show Kitchen-managed process status
make hello-doh      # Run Kitchen validation tests
```

### Common Kitchen Issues
- **Permission errors**: Kitchen requires `export UID && export GID=$(id -g)`
- **Port conflicts**: Modify Kitchen-generated `docker-compose.env` ports
- **SSL issues**: Regenerate Kitchen certificates with `make ssl-setup`
- **Template errors**: Verify all @AI-Kitchen instructions processed correctly

### Kitchen Debug Strategy
1. **Check INITDEV.md** - Kitchen generates project-specific troubleshooting guide
2. **Review Kitchen logs** - All services log to `./var/log/` directories  
3. **Validate Kitchen processing** - Ensure no {{placeholders}} remain in generated files
4. **Verify Kitchen templates** - Confirm @AI-Kitchen instructions executed properly

## Advanced Kitchen Features

### Kitchen Directory Flexibility
```bash
/doh:init-dev "Django in ./infra"      # Custom container directory
/doh:init-dev "Laravel in ./services"  # Override Kitchen defaults
```

### Kitchen Multi-Technology Support
- **Full-stack Kitchen**: Backend + Frontend + Database coordination
- **API Kitchen**: Backend + Database + worker processes
- **Frontend Kitchen**: Static generation + build tools
- **Microservices Kitchen**: Multiple service orchestration

### Kitchen Extensions
- **Testing integration** - pytest, PHPUnit, Jest framework setup
- **Linting containers** - Separate containers for version isolation
- **Worker processes** - Background job processing (Celery, Queue workers)
- **Development tools** - Database admin interfaces, mail testing

## Kitchen Core Template Processing Rules

This section contains the authoritative technical rules for Kitchen core template processing.

### Core Seed Files Location

**@AI-Kitchen: MANDATORY - Core templates location**
All seed/core files are located in `.claude/templates/init-dev/core/`:

| File | Purpose | Kitchen Rules |
|------|---------|---------------|
| `Makefile.seed` | Foundation Makefile | Can be kitchened, diff must show clean changes |
| `docker-compose-base.yml` | Base service definitions | Base services with placeholders |
| `docker-compose.env-docker` | Environment variables | Template with placeholders |
| `Dockerfile.multi-stage` | Multi-stage Docker base | Conditional stages per framework |
| `.env` | Application environment | Framework-specific variables |
| `.env.test` | Test environment | Isolated test configuration |
| `traefik/` | Traefik SSL/routing | Project-specific certificates |
| `scripts/` | Common utility scripts | Universal helper scripts |

### Makefile.seed - Foundation Rules

**@AI-Kitchen: MERGE - Makefile composition rules**

#### Mandatory Preservation Patterns
The `Makefile.seed` is the **core foundation** that MUST be respected:

```makefile
# Seed structure that MUST be preserved:
# 1. Variable definitions (DOCKER_COMPOSE, EXEC_CONTAINER, etc.)
# 2. Core targets (env-config, copy-dist-config, dev, dev-setup)  
# 3. Help system (help target with descriptions)
# 4. Essential patterns (UID/GID export, error handling)
```

#### Kitchen Processing Rules
1. **Read complete seed** - Load entire Makefile.seed content
2. **Process @AI-Kitchen tags** - Apply SUBSTITUTE/CONDITIONAL instructions in seed
3. **Replace placeholders** - Transform {{PROJECT_NAME}} → real project name
4. **Add framework extensions** - Append framework-specific targets AFTER seed
5. **Validate diff** - `diff Makefile.seed Makefile` shows only clean, understandable additions

#### Framework Extension Pattern
```makefile
# Final Makefile structure:
# [Complete processed Makefile.seed content]
# 
# # ==========================================
# # FRAMEWORK-SPECIFIC EXTENSIONS
# # ==========================================
#
# [Framework targets from stacks/*/Makefile.*-part]
```

### Core Template Processing Rules

#### @AI-Kitchen Instructions in Core Files

**SUBSTITUTE** - Standard placeholders:
- `{{PROJECT_NAME}}` → Actual project name
- `{{EXTERNAL_HTTP_PORT}}` → HTTP port (8000, 8080)
- `{{EXTERNAL_HTTPS_PORT}}` → HTTPS port (8443, 4430)  
- `{{EXTERNAL_TRAEFIK_PORT}}` → Traefik dashboard port (8080, 8081)

**CONDITIONAL** - Framework detection:
- Database detected → Include database service in docker-compose
- Frontend detected → Include Node.js stages in Dockerfile
- Background jobs → Include worker processes in supervisord

**MERGE** - Combination rules:
- Environment files: Base template + framework-specific additions
- Docker compose: Base services + detected stack services
- Gitignore: Universal patterns + framework-specific patterns

### Directory Structure Generation

**@AI-Kitchen: GENERATE - Standard Docker layout**

#### Generated Project Structure
```
project-name/
├── docker/
│   ├── app/
│   │   ├── Dockerfile              # From core/Dockerfile.multi-stage
│   │   └── supervisord.conf        # Framework-specific process management
│   ├── {database}/                 # mariadb/, postgres/ (conditional)
│   │   └── conf.d/                 # Database-specific configurations
│   └── traefik/
│       ├── certs/                  # SSL certificates (mkcert generated)
│       └── etc/
│           ├── traefik.yaml        # From core/traefik/etc/traefik.yaml-docker
│           └── dynamic.yaml        # From core/traefik/etc/dynamic.yaml-docker
├── var/
│   ├── data/
│   │   └── {database}/            # Database data persistence
│   ├── log/
│   │   ├── app/                   # Application logs
│   │   ├── {database}/            # Database logs
│   │   └── traefik/               # Traefik access/error logs
│   └── tmp/                       # Temporary files
├── Makefile                       # From core/Makefile.seed + framework parts
├── docker-compose.yml             # From core/docker-compose-base.yml + services
├── .env                           # From core/env + framework vars
├── .env.test                      # From core/env.test + test config
└── .gitignore                     # From core/gitignore + framework
```

### File Copy vs Template Processing

**@AI-Kitchen: Copy Rules - Core vs Framework files**

#### Direct Copy (no processing)
Files that are copied as-is without template processing:
- `scripts/` → Copy entire directory structure
- Binary files, certificates (when they exist)

#### Template Processing (placeholders + @AI-Kitchen)
Files that require template transformation:
- Template files → Process placeholders and @AI-Kitchen tags
- `*-docker` files → Process placeholders, copy to local names
- `Makefile.seed` → Process and merge with framework parts

#### Framework Additions
Files that are merged/extended:
- `Makefile.seed` + `stacks/*/Makefile.*-part` → Final Makefile
- `docker-compose-base.yml` + `services/*/*.yml` → Final docker-compose.yml
- `env` + framework environment → Final .env

### Validation Rules

#### Post-Processing Validation
**@AI-Kitchen: Validation - Zero placeholders rule**

1. **Placeholder Scan**: `grep -r "{{" generated-files/` must return EMPTY
2. **File Existence**: All core files must generate corresponding local files
3. **Makefile Syntax**: Final Makefile must be valid make syntax
4. **Docker Validation**: `docker compose config` must pass without errors
5. **Permission Check**: All generated files must have correct permissions

#### Error Recovery Patterns
```bash
# Common fixes for generation failures:

# Placeholder remaining → Check framework mappings
grep "{{" *.docker

# Makefile syntax error → Check framework part syntax
make -n help

# Docker compose error → Validate service definitions
docker compose config

# Permission errors → Ensure UID/GID export
export UID && export GID=$(id -g)
```

### Integration with Framework Detection

#### Framework-Specific Core Modifications

**Python/Django** modifications to core:
- `Dockerfile.multi-stage` → Add Python dependencies
- `env` → Add DJANGO_SETTINGS_MODULE
- `Makefile.seed` processing → Add Django-specific variables

**PHP/Laravel** modifications to core:  
- `Dockerfile.multi-stage` → Add Composer stage
- `env` → Add APP_KEY generation
- `Makefile.seed` processing → Add Composer/Artisan commands

**Node.js** modifications to core:
- `Dockerfile.multi-stage` → Simpler single-stage (Node.js only)
- `env` → Add NODE_ENV configuration
- `Makefile.seed` processing → Add npm/yarn commands

## Kitchen References & Documentation

- **Kitchen Processing Rules**: See "Kitchen Core Template Processing Rules" section above - **AUTHORITATIVE** core template processing rules
- **Kitchen Detection**: [DETECT.md](.claude/templates/init-dev/DETECT.md) - Framework detection methodology
- **Kitchen Placeholders**: [PLACEHOLDERS.md](.claude/templates/init-dev/PLACEHOLDERS.md) - Template substitution system
- **Kitchen Environment Layers**: [ENV.md](.claude/templates/init-dev/ENV.md) - Multi-layer environment configuration system
- **Kitchen Validation**: [HELLOWORLD.md](.claude/templates/init-dev/HELLOWORLD.md) - Three-phase testing principles  
- **Kitchen Docker Patterns**: [DOCKER.md](.claude/templates/init-dev/DOCKER.md) - Container configuration details

---

💡 **The DOH Kitchen system evolves** - contribute improvements to Kitchen templates and processing logic