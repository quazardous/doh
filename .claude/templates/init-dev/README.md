# Init-Dev Templates

## 🍳 Component "Kitchen" - Not Traditional Templates!

**IMPORTANT**: These files are **NOT traditional templates** but rather a **"kitchen"** of modular components that the AI combines intelligently.

### Why "Kitchen" instead of "Templates"?

🚫 **Traditional templates** = Static files with a few `{{VAR}}` variables  
✅ **DOH Kitchen** = Modular components that AI assembles dynamically

**The key difference:**
- AI **doesn't copy** these files as-is
- AI **takes inspiration** from patterns and structures  
- AI **combines** multiple components based on detected stack
- AI **researches** current versions via Docker Hub API
- AI **adapts** configurations to current best practices

### How AI uses this "Kitchen":

1. **Stack detection** → AI examines the project
2. **Cherry-picking** → AI selects relevant components  
3. **Real-time research** → Docker Hub API + WebSearch best practices
4. **Intelligent assembly** → AI generates custom files
5. **Validation** → AI tests that everything works

**Concrete example:**
```
Django project detected → AI takes inspiration from stacks/python/ + services/mysql.yml  
→ Research Django latest via Docker Hub API
→ Search "Django MariaDB best practices 2024"  
→ Generate container-organized structure in ./docker/
   ├── docker-compose.yml (custom with current versions)
   ├── app/Dockerfile (adapted from stacks/python/Dockerfile)
   ├── linter/Dockerfile (adapted from stacks/python/Dockerfile.linter)
   ├── app/supervisord.conf (web + worker processes)
   ├── traefik/traefik.yml (HTTPS configuration)
   └── mariadb/conf.d/custom.cnf
```

## Structure (Container-Organized)

**🔍 STRUCTURE ACTUELLE (Templates "Kitchen"):**

```
.claude/templates/init-dev/
├── core/                            # Common components for all stacks
│   ├── docker-compose-base.yml        # Base docker-compose structure
│   ├── Dockerfile.multi-stage # Multi-stage Dockerfile template
│   └── Makefile.seed                   # Foundation Makefile extended by framework parts
├── stacks/                          # Stack-specific patterns
│   ├── node/                        # Node.js stack templates
│   │   ├── Dockerfile                  # Node.js main container
│   │   ├── Dockerfile.linter           # Node.js linting container
│   │   ├── service.yml                 # Docker compose service definition
│   │   └── linter.yml                  # Linter configuration
│   ├── php/                         # PHP stack templates  
│   │   ├── Dockerfile                  # PHP main container (with composer)
│   │   ├── Dockerfile.linter           # PHP linting container
│   │   ├── service.yml                 # Docker compose service definition
│   │   └── linter.yml                  # Linter configuration
│   └── python/                      # Python stack templates
│       ├── Dockerfile                  # Python main container
│       ├── Dockerfile.linter           # Python linting container  
│       ├── service.yml                 # Docker compose service definition
│       └── linter.yml                  # Linter configuration
└── services/                        # Modular Docker services
    ├── postgres.yml                 # PostgreSQL + Adminer
    ├── mysql.yml                    # MySQL + phpMyAdmin
    ├── redis.yml                    # Redis
    └── mailhog.yml                  # MailHog

🚨 NOTE: This structure serves as INSPIRATION for AI, which then generates 
         the final container-organized structure in ./docker/app/, ./docker/linter/, etc.
```

## How AI Uses This Kitchen

The `/doh:init-dev` command uses this "kitchen" to generate custom development environments. AI does **NOT** simply copy/replace variables:

### Extending the "Kitchen"

To enrich components available to AI, add to the **existing structure**:

1. **New stacks**: Add directories in `stacks/` (Go, Rust, etc.)
   - `stacks/go/Dockerfile`, `stacks/go/Dockerfile.linter`
   - `stacks/rust/Dockerfile`, `stacks/rust/Dockerfile.linter`

2. **New services**: Create patterns in `services/` (Elasticsearch, etc.)
   - `services/elasticsearch.yml`
   - `services/prometheus.yml`

3. **New linters**: Add stack-specific `Dockerfile.linter` in each `stacks/` directory
   - `stacks/go/Dockerfile.linter` (golangci-lint, gofmt)
   - `stacks/rust/Dockerfile.linter` (clippy, rustfmt)

4. **New patterns**: Enhance existing `service.yml` and `linter.yml` files

**Important**: AI adapts these templates to generate container-organized final structure!

### AI Kitchen Pseudo-Tags and Dynamic Generation

**@AI-Kitchen: Pseudo-Tag System** guides intelligent generation:

```makefile
# @AI-Kitchen: CONDITIONAL - Include if Redis detected in stack
# @AI-Kitchen: CHOOSE - Replace npm with yarn/pnpm if detected
# @AI-Kitchen: MERGE - Add to seed env-config target
# @AI-Kitchen: SUBSTITUTE - Replace {{PROJECT_NAME}} with real project name
# @AI-Kitchen: GENERATE - Create framework-specific hello-world validation
```

AI generates variables **on-the-fly** based on context:
- `PROJECT_NAME` → Detected from directory name
- `FRAMEWORK_VERSION` → Researched via Docker Hub API  
- `DB_TYPE` → Inferred from stack or user specification
- And many others based on detected needs...

**Makefile Architecture**: AI combines `Makefile.seed` (foundation) + `Makefile.*-part` (framework extensions) → Final `Makefile`

**Distribution File Pattern**: `-docker` suffix files contain working defaults that copy to local customizable versions via `make env-config`

### Permission Management (UID/GID)

**⚠️ UID/GID are NOT in the templates**

Permissions are handled automatically by:

**Option 1 - Via Makefile**:
```make
export UID := $(shell id -u)  # Makefile syntax
export GID := $(shell id -g)
```

**Option 2 - Via bash script**:
```bash
export UID     # UID is already defined in bash
export GID=$(id -g)
```

**Common flow**:
```
Detection (make/script) → docker-compose.yml (args:) → Dockerfile (application)
```

In all cases:
- **docker-compose.yml** passes via `args:` to Dockerfiles during build
- **Dockerfiles** create/modify internal user with host UID/GID

No manual UID/GID configuration needed.

### Dependency Versions - ALWAYS Current

🚨 **Versions in this "kitchen" are ignored** - AI ALWAYS uses current versions!

**AI process for versions:**
1. **Docker Hub API Priority** → `https://hub.docker.com/v2/repositories/library/{image}/tags/`
2. **Intelligent filtering** → Stable versions only (skip alpha/beta/rc)
3. **LTS preferences** → Node.js LTS, Python stable, etc.
4. **Optimal variants** → `-slim`, `-alpine` when appropriate

**Sources used by AI:**
- **Docker images**: Docker Hub API (always priority)
- **Best practices**: Real-time WebSearch for configurations
- **Offline fallback**: Only if APIs unavailable

**Result**: Generated stack = Latest stable versions of the moment!

### Single Container Architecture with Multi-Stage Builds

**Core DOH Principle**: One unified container that combines multiple technologies using Docker multi-stage builds.

**Multi-Stage FROM/COPY Cascade Pattern:**
```dockerfile
# AI detects stack → generates appropriate stages
FROM node:20 AS node-tools         # If frontend detected  
FROM composer:2 AS composer-tools   # 🚨 ONLY IF PHP DETECTED (Laravel, Symfony)
FROM python:3.12 AS python-tools    # If Python detected

FROM php:8.3-fpm  # Backend framework as final image

# Cherry-pick Node.js tools (AI-conditional)
COPY --from=node-tools /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-tools /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Cherry-pick Composer (🚨 ONLY FOR PHP - Laravel/Symfony/etc.)
COPY --from=composer-tools /usr/bin/composer /usr/bin/composer

# System dependencies (AI-detected)
RUN apt-get update && apt-get install -y git sudo supervisor unzip
```

**AI Stack Detection → Base Image Strategy:**
```text
Laravel/Symfony + frontend → FROM composer:2 + FROM node:20 → php:8.3-fpm
Laravel/Symfony alone → FROM composer:2 → php:8.3-fpm
Django + React → FROM python:3.12 + FROM node:20 → python:3.12-slim
Django alone → FROM python:3.12-slim
Rails + Webpack → FROM ruby:3.2 + FROM node:20 → ruby:3.2-slim
Node.js pure → FROM node:20-alpine (no multi-stage needed)

Rule: Backend framework technology ALWAYS as final image (simplicity)
```

**Benefits of Single Container + Multi-Stage:**
- ✅ **Unified access**: `make sh` enters container with all tools available
- ✅ **No namespace pollution**: No multiple app containers cluttering docker ps
- ✅ **Simplified development**: All tools in one place for debugging
- ✅ **Process management**: Supervisord manages web + workers + schedulers together  
- ✅ **Efficient builds**: Only copy what's needed from each stage
- ✅ **Tool isolation**: Build stages isolated, final image optimized

**What AI copies between stages:**
- ✅ **System binaries**: `/usr/bin/composer`, `/usr/local/bin/node`
- ✅ **Tool installations**: Globally installed packages and executables
- ✅ **System daemon configs**: `/etc/mysql/`, `/etc/postgresql/` (when applicable)

**What AI NEVER copies (uses volume mounts instead):**
- ❌ **Application code**: Always volume mounted from host for hot-reload
- ❌ **User-level configs**: Always volume mounted for easy editing
- ❌ **Library dependencies**: Always installed post-build via Makefile for speed
- ❌ **Data**: Always volume mounted for persistence

### Library Dependencies: Post-Build Installation Strategy

**🚨 CRITICAL**: Dependencies (composer, npm, pip) are installed AFTER Docker build, not during build!

**Why post-build dependency installation:**
```dockerfile
# ❌ FORBIDDEN in DOH Dockerfile
COPY package.json ./
RUN npm install             # ❌ Slow rebuild on every dependency change

COPY composer.json ./
RUN composer install        # ❌ Slow rebuild on every dependency change

COPY requirements.txt ./
RUN pip install -r requirements.txt  # ❌ Slow rebuild on every dependency change
```

**✅ DOH Approach - Dockerfile only system tools:**
```dockerfile
# ✅ Dockerfile - Runtime + system tools only
FROM python:3.12-slim
RUN apt-get update && apt-get install -y build-essential git nodejs npm
# No dependency installation in build!
```

**✅ Dependencies managed post-build via Makefile:**
```makefile
# ✅ Makefile - Dependencies post-build by stack
dev-setup:
	@echo "Installing Python dependencies..."
	docker compose run --rm app pip install -r requirements.txt
	@echo "Installing Node.js dependencies for frontend..."
	docker compose run --rm app npm install
	@echo "Running database migrations..."
	docker compose run --rm app python manage.py migrate

# Fast dependency updates without container rebuild
update-deps:
	docker compose run --rm app pip install -r requirements.txt
	docker compose run --rm app npm install
```

**Benefits of post-build dependencies:**
- ✅ **Fast Docker builds** - Only runtime changes trigger rebuild (seconds vs minutes)
- ✅ **Fast dependency updates** - `make update-deps` without container rebuild  
- ✅ **Instant code changes** - Volume mounts for immediate feedback
- ✅ **Better caching** - System tools vs application dependencies separation
- ✅ **Flexible workflows** - `make dev`, `make update-deps`, `make clean-deps`

### Linting Containers

Each stack includes a separate linting container (`linter.yml` + `Dockerfile.linter`) to:
- ✅ Avoid tool version conflicts
- ✅ Standardize tools for the team
- ✅ Enable reproducible linting environments

**Linter usage**:
```bash
# Start the linting container
docker compose --profile tools up -d linter

# Use linting tools
docker compose exec linter eslint src/        # Node.js
docker compose exec linter phpstan analyze   # PHP  
docker compose exec linter black .           # Python
```

### Dotenv Support (.env)

All stacks include dotenv support for environment variable management:

**Node.js**: `dotenv` package with `require('dotenv').config()`
**PHP**: `vlucas/phpdotenv` package with `Dotenv::createImmutable()`  
**Python**: `python-dotenv` package with `load_dotenv()`

**Usage flow**:
```bash
# 1. Copy environment template
cp docker-compose.env .env

# 2. Edit local variables
# .env git handling is YOUR choice

# 3. Application automatically loads .env
# Variables available in process.env / $_ENV / os.getenv()
```

**Security**:
- `.env` - YOU decide whether to git-ignore it or not
- `docker-compose.env-docker` is versioned as example template
- Sensitive variables to mask in debug logs per your needs

**DOH_HELLOWORLD Best Practice**:
- `DOH_HELLOWORLD` MUST be in `.env` file (application environment)
- `DOH_HELLOWORLD` should NOT be in `docker-compose.env` (Docker configuration)
- Auto-generated per environment using `date +%s | md5sum | cut -d' ' -f1`
- Used for Hello World validation and frontend/backend integration testing

### Container Organization

The AI generates a **container-organized structure** where each service has its own dedicated folder:

**Main Application Container (`./docker/app/`)**:
- **Dockerfile**: Multi-stage build combining all needed tools (Python + Node.js, PHP + Composer, etc.)
- **supervisord.conf**: Process management (web server + workers + background tasks)
- **scripts/**: Container-specific installation and management scripts

**Linter Container (`./docker/linter/`)**:
- **Dockerfile**: Separate linting container to avoid version conflicts with main app
- Contains all code quality tools (Black, ESLint, PHPStan, etc.) for the detected stack

**Reverse Proxy Container (`./docker/traefik/`)**:
- **traefik.yml**: Dynamic routing configuration
- **certs/**: SSL certificates directory (auto-generated)

**Database Container (`./docker/mariadb/` or `./docker/postgres/`)**:
- **init/**: Database initialization scripts
- **conf.d/**: Custom database configuration files

**Shared Data Directory (`./docker/var/`)** 🚨 **EXCEPTION**:
- **data/**: Persistent data volumes (database, cache, etc.)
- **log/**: Runtime logs from all containers (app, traefik, mariadb, supervisor)

**Typical development workflow**:
```bash
cd docker/       # Enter the container-organized directory
make dev         # Start entire development stack
make sh          # Enter the main app container
                 # - All tools available (Django + Node.js + linters)
                 # - Debug your code
                 # - Install packages
                 # - Run framework commands
                 
make db-shell    # Enter database container if needed
```

**Container Responsibilities**:
- `app` = **Main development container** with all frameworks and tools
- `linter` = **Code quality tools** (ESLint, Black, PHPStan, etc.) - separate to avoid conflicts
- `traefik` = **Reverse proxy** with automatic HTTPS and routing
- `mariadb/postgres` = **Database** with persistent data in `./data/`

**Container-Specific Benefits**:
- ✅ **Clear separation**: Each container has its dedicated sub-folder for configs/builds
- ✅ **Easy debugging**: Container issues isolated to their specific folder
- ✅ **Better maintenance**: Update container configs without affecting others
- ✅ **Team collaboration**: Developers can focus on specific container responsibilities
- ✅ **Data exceptions**: Shared data (`./var/data/`) and logs (`./var/log/`) centralized for easy access

## Limitations and Extensions

### These components are minimal bases

- **Node.js**: Basic ESLint/Prettier configuration
- **PHP**: Generic Laravel/Symfony setup
- **Python**: Simple Django/FastAPI configuration

### Suggested extensions

- Unit and integration tests
- CI/CD pipelines
- Monitoring and observability
- Advanced security configuration
- Performance optimizations

## Contribution

To extend or improve these components:

1. Follow the existing structure
2. Document new substitution variables
3. Test with different projects
4. Maintain simplicity for easier adoption

**Principle**: This "kitchen" should remain a simple **source of inspiration** for AI, not frozen solutions.

## 🎯 Summary: Kitchen vs Templates

| Aspect | Traditional Templates | DOH Kitchen |
|--------|---------------------|-------------|
| **Usage** | Copy + variable replacement | Inspiration + intelligent assembly |
| **Versions** | Frozen in files | Real-time research (Docker Hub API) |
| **Adaptability** | Limited to planned variables | AI adapts to detected context |
| **Maintenance** | Versions become obsolete quickly | Always up-to-date automatically |
| **Complexity** | Simple but rigid | Intelligent and flexible |

**The DOH advantage**: AI combines the best components with the latest versions and current best practices!

## 🗂️ Container-Organized Architecture (New)

### Why Container Organization?

The new container-organized approach provides better **separation of concerns** and **maintainability**:

✅ **Clear responsibilities**: Each container has its own folder with specific configs  
✅ **Easy debugging**: Find container-specific issues faster  
✅ **Better scaling**: Add new containers without cluttering the main directory  
✅ **Team collaboration**: Developers can focus on specific container configurations  
✅ **Production alignment**: Mirror production multi-container setups in development

### Generated Structure Example

```
./docker/                           # User-specified directory (e.g., ./docker, ./infra, ./containers)
├── docker-compose.yml              # Main orchestration
├── docker-compose.env              # Environment variables
├── Makefile                        # Development commands (generated from Makefile.seed + framework parts)
├── app/                            # Main application container ⭐ MANDATORY
│   ├── Dockerfile                  # Multi-stage: Python + Node.js + System tools
│   ├── supervisord.conf            # Process management (web + workers + scheduler)
│   └── scripts/                    # App-specific automation
│       ├── install-deps.sh         # Dependencies installation
│       └── setup-hooks.sh          # Git hooks or other setup
├── linter/                         # Code quality container (profile-based)
│   └── Dockerfile                  # Linting tools (Black, ESLint, PHPStan, etc.)
├── traefik/                        # Reverse proxy container
│   ├── traefik.yml                 # Dynamic routing + HTTPS configuration
│   └── certs/                      # SSL certificates (mkcert generated)
├── mariadb/                        # Database container (when applicable)
│   ├── init/                       # Database initialization scripts
│   │   └── custom.cnf              # Database configuration
│   └── conf.d/                     # Custom database configuration
│       └── custom.cnf              # Performance and charset settings
├── shared/                         # Cross-container shared resources
│   ├── scripts/                    # Scripts used by multiple containers
│   └── configs/                    # Shared configuration templates
└── var/                            # 🚨 EXCEPTION: Shared data/logs (gitignored)
    ├── data/                       # Persistent data volumes
    │   └── mariadb/                # Database data persistence
    └── log/                        # Runtime logs from all containers
        ├── app/                    # Application logs
        ├── traefik/                # Traefik logs
        ├── mariadb/                # Database logs
        └── supervisor/             # Process management logs
```

### Container-Specific Benefits

**Main App Container (`./docker/app/`)**:
- 🎯 **Single entry point**: All development tools in one container (`make sh`)
- 🔧 **Multi-technology**: Python + Node.js + database clients in unified environment
- 🔄 **Process management**: Web server + background workers via supervisord
- 📦 **Volume mounts**: Application code mounted for hot-reload development

**Traefik Container (`./docker/traefik/`)**:
- 🌐 **Auto HTTPS**: SSL certificates automatically managed with mkcert
- 🔀 **Smart routing**: `https://app.project.localhost`, `https://adminer.project.localhost`
- 📊 **Dashboard**: Available at `http://localhost:8080` for debugging routes

**Database Container (`./docker/mariadb/` or `./docker/postgres/`)**:
- 🗄️ **Data persistence**: Database data stored in `./var/data/mariadb/` (shared exception)
- ⚙️ **Custom config**: Performance tuning in `./mariadb/conf.d/` (container-specific)
- 🚀 **Auto initialization**: Database and users created via environment variables (MARIADB_DATABASE, MARIADB_USER, etc.)
- 📝 **Logs**: Database logs in `./var/log/mariadb/` (shared exception)

### Migration Path

**From flat structure**:
```bash
# Old approach (still supported for backward compatibility)
./docker/
├── docker-compose.yml
├── Dockerfile
├── traefik.yml
└── data/
```

**To container-organized structure** (new default):
```bash
# New approach (recommended for new projects)
./docker/
├── docker-compose.yml
├── app/Dockerfile
├── traefik/traefik.yml
└── data/
```

The AI automatically detects existing structures and can adapt both approaches based on user preference or project context.