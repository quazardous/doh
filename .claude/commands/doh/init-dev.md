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

### Docker Hub API Version Detection (Primary Source)

**API Endpoint Pattern:**
```text
Repository search: https://hub.docker.com/v2/search/repositories/?query={image_name}
Tags retrieval: https://hub.docker.com/v2/repositories/{namespace}/{image_name}/tags/?page_size=50
Official images: https://hub.docker.com/v2/repositories/library/{image_name}/tags/?page_size=50
```

**Version Extraction Logic:**
1. **Fetch latest tags**: Sort by `last_updated` timestamp (most recent first)
2. **Filter semantic versions**: Prioritize tags matching `vX.Y.Z` or `X.Y.Z` patterns  
3. **Exclude pre-releases**: Skip `alpha`, `beta`, `rc`, `dev` tags for stable versions
4. **LTS detection**: For Node.js, prefer `lts-*` variants when available
5. **Slim variants**: Prefer `-slim`, `-alpine` for smaller image sizes where appropriate

**Implementation Example with Error Handling:**
```javascript
// AI extracts version from Docker Hub API response with error handling
async function getLatestDockerVersion(namespace = 'library', image, retries = 3) {
  const url = `https://hub.docker.com/v2/repositories/${namespace}/${image}/tags/?page_size=50`;
  
  try {
    const response = await fetch(url);
    
    // Handle rate limiting
    if (response.status === 429) {
      const retryAfter = response.headers.get('Retry-After') || 60;
      throw new Error(`Rate limited. Retry after ${retryAfter} seconds`);
    }
    
    if (!response.ok) {
      throw new Error(`Docker Hub API error: ${response.status}`);
    }
    
    const data = await response.json();
    
    const versions = data.results
      .filter(tag => /^v?\d+\.\d+(\.\d+)?(-slim|-alpine)?$/.test(tag.name))
      .filter(tag => !/(alpha|beta|rc|dev|test)/i.test(tag.name))
      .sort((a, b) => new Date(b.last_updated) - new Date(a.last_updated))
      .map(tag => ({
        version: tag.name,
        updated: tag.last_updated,
        size: tag.full_size
      }));

    return versions[0] || null; // Most recent stable version
    
  } catch (error) {
    if (retries > 0) {
      await new Promise(resolve => setTimeout(resolve, 1000));
      return getLatestDockerVersion(namespace, image, retries - 1);
    }
    
    // Fallback to template defaults
    console.warn(`Docker Hub API failed for ${image}, using fallback`);
    return getTemplateDefault(image);
  }
}
```

**Fallback Strategy:**
- **Primary**: Docker Hub API (always up-to-date, official)
- **Secondary**: WebSearch for best practices refinement only  
- **Tertiary**: Template defaults from `.claude/templates/init-dev/offline-defaults.json`

**Source Selection by Technology (Docker Hub API Priority):**
```text
PHP → Docker Hub API https://hub.docker.com/v2/repositories/library/php/tags/?page_size=50 (primary)
     → WebSearch "PHP 8.3 best practices site:php.net" (fallback for best practices only)
Python → Docker Hub API https://hub.docker.com/v2/repositories/library/python/tags/?page_size=50 (primary)
       → WebSearch "Python development best practices site:python.org" + PyPI trends (fallback for best practices)
Node.js → Docker Hub API https://hub.docker.com/v2/repositories/library/node/tags/?page_size=50 (primary)  
        → WebSearch "Node.js development best practices site:nodejs.org" + npm registry (fallback for best practices)
Java → Docker Hub API https://hub.docker.com/v2/repositories/library/openjdk/tags/?page_size=50 (primary)
     → WebSearch "OpenJDK best practices site:openjdk.org" + Maven Central (fallback for best practices)
.NET → Docker Hub API https://hub.docker.com/v2/repositories/microsoft/dotnet/tags/?page_size=50 (primary)
     → WebSearch "dotnet best practices site:dotnet.microsoft.com" + NuGet (fallback for best practices)
Go → Docker Hub API https://hub.docker.com/v2/repositories/library/golang/tags/?page_size=50 (primary)
   → WebSearch "Go development best practices site:golang.org" + pkg.go.dev (fallback for best practices)
Rust → Docker Hub API https://hub.docker.com/v2/repositories/library/rust/tags/?page_size=50 (primary)
     → WebSearch "Rust development best practices site:rust-lang.org" + crates.io (fallback for best practices)
C++ → Docker Hub API https://hub.docker.com/v2/repositories/library/gcc/tags/?page_size=50 (primary)
    → WebSearch "GCC development best practices" + vcpkg/Conan (fallback for best practices)
Ruby → Docker Hub API https://hub.docker.com/v2/repositories/library/ruby/tags/?page_size=50 (primary)
     → WebSearch "Ruby development best practices site:ruby-lang.org" + rubygems.org (fallback for best practices)
```

**Framework-Specific Research (Best Practices Focus - NO Version Detection):**
```text  
Laravel → WebSearch "Laravel development best practices site:laravel.com" + Queue workers patterns
         + "Laravel testing best practices APP_ENV" + "Laravel Mix dotenv frontend"
         + Packagist trends for popular packages only
Django → WebSearch "Django development best practices site:djangoproject.com" + Celery workers patterns  
         + "Django testing pytest settings" + "Django webpack dotenv integration"
         + PyPI trends for popular packages only
Rails → WebSearch "Rails development best practices site:rubyonrails.org" + Sidekiq workers patterns
        + "Rails test environment configuration" + "Rails webpacker dotenv"
        + RubyGems trends for popular gems only
Spring Boot → WebSearch "Spring Boot development best practices site:spring.io" + async processing patterns
              + "Spring Boot test profiles" + "Spring Boot frontend environment variables"
              + Maven Central trends for popular libraries only
Express → WebSearch "Express.js development best practices" + worker processes patterns
          + "Node.js testing with dotenv" + "webpack dotenv plugin configuration"
          + npm registry trends for popular packages only

🚨 IMPORTANT: WebSearch is NO LONGER used for version detection - only for:
- Development best practices and patterns
- Framework-specific configuration recommendations  
- Popular package/library trend analysis
- Testing and debugging strategies
- Architectural pattern recommendations
```

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

### Technology Association Logic & Best Practices vs Pitfalls

**Multi-Technology Stack Best Practices:**
```text
🎯 GOOD PRACTICES (Statistical Winners):

✅ Laravel + Vue.js + MySQL + Redis:
   → WebSearch "Laravel Vue Inertia.js best practices full-stack development"
   → WebSearch "Laravel Redis sessions cache queue best practices"
   → Strong ecosystem integration, official support

✅ Django + React + PostgreSQL + Celery:
   → WebSearch "Django React DRF best practices API development"  
   → WebSearch "Django Celery PostgreSQL best practices async tasks"
   → Mature patterns, excellent documentation

✅ Node.js + React + MongoDB + Redis:
   → WebSearch "Node.js React Next.js best practices full-stack JavaScript"
   → WebSearch "Node.js MongoDB Redis best practices session management"
   → JavaScript ecosystem consistency

✅ Spring Boot + Angular + PostgreSQL + RabbitMQ:
   → WebSearch "Spring Boot Angular best practices enterprise development"
   → WebSearch "Spring Boot RabbitMQ best practices message processing"
   → Enterprise-grade stability

⚠️ PITFALLS TO AVOID (Anti-Patterns):

❌ Laravel + Angular (Framework Conflict):
   → Problem: Laravel Blade vs Angular templating conflicts
   → Better: Laravel API + Angular SPA OR Laravel + Vue.js

❌ Django + PHP Frontend Tools:
   → Problem: Python/PHP tooling conflicts, different ecosystems
   → Better: Django + React/Vue OR PHP + Vue.js

❌ Node.js + MySQL + Synchronous Operations:
   → Problem: Blocking operations kill Node.js performance
   → Better: Node.js + MongoDB OR Node.js + PostgreSQL with async/await

❌ Spring Boot + MongoDB + Complex Joins:
   → Problem: MongoDB lacks SQL joins, Spring Data limitations
   → Better: Spring Boot + PostgreSQL OR Node.js + MongoDB

❌ Multiple Frontend Frameworks (React + Vue + Angular):
   → Problem: Bundle size explosion, maintenance hell
   → Better: Pick ONE frontend framework per project

❌ Multiple Databases Without Clear Purpose:
   → Problem: Data consistency issues, complex migrations
   → Better: Single primary DB + Redis for caching only
```

**Association Logic Guidelines:**
```text
🔍 DETECTION PRIORITY LOGIC:

1. Framework Detection → Database Recommendation:
   detect_framework() → statistical_db_pairing() → best_practices_research()
   
   Example:
   Laravel detected → MySQL (60% default) → Laravel MySQL best practices
   Django detected → PostgreSQL (70% default) → Django PostgreSQL best practices

2. Frontend Detection + Backend → Integration Patterns:
   detect_frontend() + detect_backend() → integration_research()
   
   Example:
   React + Laravel → Inertia.js patterns research
   Vue + Django → DRF + Vue SPA patterns research

3. Worker/Queue Detection → Broker Recommendation:
   detect_workers() → statistical_broker_pairing() → configuration_research()
   
   Example:
   Celery detected → Redis broker (80% default) → Django Celery Redis best practices
   Laravel Queue → Redis (70%) OR database (30%) → Laravel Queue best practices

🚨 CONFLICT RESOLUTION LOGIC:

When Multiple Technologies Detected:
1. Check compatibility matrix
2. Warn about known conflicts  
3. Suggest alternative combinations
4. Research integration patterns for chosen stack

Example Conflict Resolution:
```javascript
if (framework === 'Laravel' && frontend === 'Angular') {
  warn('Laravel + Angular has templating conflicts')
  suggest('Consider: Laravel API + Angular SPA OR Laravel + Vue.js')
  research('Laravel SPA API development best practices')
}

if (database === 'MongoDB' && framework === 'Spring Boot' && complex_queries) {
  warn('MongoDB + Spring Boot not optimal for complex joins')
  suggest('Consider: PostgreSQL + Spring Boot OR Node.js + MongoDB')
  research('Spring Boot PostgreSQL JPA best practices')
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

**Framework-Specific Tool Requirements (AI-Detected via WebSearch):**

**🔍 DISCOVERY VIA WEBSEARCH:**
AI uses WebSearch to discover satellite tools specific to each technology:
- `"Django development requirements tools 2024"` → Discovers pip, python3-dev, libpq-dev
- `"Laravel development requirements tools 2024"` → Discovers composer, php-fpm, unzip
- `"Go development requirements tools 2024"` → Discovers go mod, ca-certificates
- `"Rust development requirements tools 2024"` → Discovers cargo, build-essential

**📊 TOOL MATRIX BY TECHNOLOGY:**

| Technology | Dependency Manager | Build Tools | Database Libs | System Tools |
|-------------|------------------|-------------|---------------|---------------|
| **PHP** (Laravel/Symfony) | `composer` | `git, unzip` | `php-mysql, php-pgsql` | `php-fpm, nginx` |
| **Python** (Django/FastAPI) | `pip` | `build-essential, python3-dev` | `libpq-dev, libmysqlclient-dev` | `git, curl` |
| **Node.js** (Express/Nest) | `npm/yarn` | `python3, build-essential` | `mysql2, pg` (via npm) | `git, curl` |
| **Go** | `go mod` | `git, ca-certificates` | Drivers via go mod | `git, curl` |
| **Rust** | `cargo` | `build-essential, gcc` | Crates via cargo | `git, curl` |
| **Ruby** (Rails) | `bundler/gem` | `build-essential, ruby-dev` | `libpq-dev, libmysqlclient-dev` | `git, curl` |
| **Java** (Spring) | `maven/gradle` | `openjdk, git` | JDBC via maven | `git, curl` |
| **.NET** | `dotnet` | `git` | NuGet packages | `git, curl` |

**🚨 CRITICAL RULE:** Each technology has its own tools - do not mix between technologies.

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

💡 **HINT PERMISSIONS:** If 403/permission errors → export UID && export GID=$(id -g) before docker compose
💡 **HINT PORTS:** If port conflicts → modify EXTERNAL_HTTP_PORT/EXTERNAL_HTTPS_PORT in docker-compose.env  
💡 **HINT SSL:** If certificates invalid → rm -rf docker/certs/* && make ssl-setup
💡 **HINT TROUBLESHOOT:** Complete logs: make logs or docker compose logs -f {{service}}

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

# Python/Django Stack
dev-setup:
	@echo "Installing Python dependencies..."
	docker compose run --rm app pip install -r requirements.txt
	@echo "Installing Node.js dependencies for frontend..."
	docker compose run --rm app npm install
	@echo "Running Django migrations..."
	docker compose run --rm app python manage.py migrate

# PHP/Laravel Stack
dev-setup:
	@echo "Installing Composer dependencies..."
	docker compose run --rm app composer install --no-dev
	@echo "Installing NPM dependencies..."
	docker compose run --rm app npm install
	@echo "Running Laravel migrations..."
	docker compose run --rm app php artisan migrate

# Node.js Stack
dev-setup:
	@echo "Installing NPM dependencies..."
	docker compose run --rm app npm install
	@echo "Running database migrations..."
	docker compose run --rm app npm run migrate

# Common targets
dev: dev-setup
	docker compose up

update-deps:
	@echo "Updating dependencies without rebuild..."
	docker compose run --rm app pip install -r requirements.txt
	docker compose run --rm app npm install

clean-deps:
	@echo "Cleaning dependency caches..."
	docker compose run --rm app rm -rf node_modules __pycache__ .pytest_cache
	
rebuild: clean-deps dev-setup
	@echo "Force rebuilding containers..."
	docker compose build --no-cache
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
  💡 **HINT:** If commands fail → check that containers are started: `docker compose ps`

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

**📦 Volume Mount Strategy (docker-compose.yml à la racine):**
```yaml
# 🚨 CRITICAL: docker-compose.yml DOIT être à la racine du projet
# Context de build: TOUJOURS "." (répertoire courant = racine projet)

services:
  app:
    build:
      context: .                                                     # 🚨 TOUJOURS "." (racine projet)
      dockerfile: ./docker/app/Dockerfile                           # Chemin depuis racine
    volumes:
      - .:/app                                                       # 🚨 Application code (racine → container)
      - ./docker/app/supervisord.conf:/etc/supervisor/supervisord.conf:ro  # App container configs
      - ./docker/scripts:/app/scripts:ro                             # Shared container scripts
      - ./var/log/app:/app/var/log                                  # App logs (racine/var/)
      - ./var/log/supervisor:/var/log/supervisor                    # Supervisor logs (racine/var/)
      
  linter:
    build:
      context: .                                                     # 🚨 TOUJOURS "." (racine projet)
      dockerfile: ./docker/linter/Dockerfile                        # Chemin depuis racine
    volumes:
      - .:/app                                                       # Application code for linting
      
  traefik:
    volumes:
      - ./docker/traefik/traefik.yml:/etc/traefik/dynamic/traefik.yml:ro   # Traefik container configs
      - ./docker/traefik/certs:/etc/ssl/certs:ro                    # SSL certificates
      - ./var/log/traefik:/var/log/traefik                          # Traefik logs (racine/var/)
      
  mariadb:
    volumes:
      - ./var/data/mariadb:/var/lib/mysql                          # Data persistence (racine/var/)
      - ./docker/mariadb/init:/docker-entrypoint-initdb.d:ro      # MariaDB init scripts
      - ./docker/mariadb/conf.d:/etc/mysql/conf.d:ro              # MariaDB container configs
      - ./var/log/mariadb:/var/log/mysql                          # MariaDB logs (racine/var/)

# 🚨 RÈGLES ORGANISATION:
# ✅ docker-compose.yml           → RACINE PROJET (context: . fonctionne)
# ✅ Container configs/builds     → ./docker/app/, ./docker/linter/, ./docker/traefik/
# ✅ Persistent data/logs         → ./var/data/, ./var/log/ (RACINE PROJET)
# ✅ Application code mount       → . (racine projet → /app dans container)
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
  💡 **HINT:** If linter fails → start with: `docker compose --profile tools up -d linter`

### Template-Based Generation
- Uses templates from `.claude/templates/init-dev/`
- **Templates are illustrations** - versions and configs adapted at runtime
- Fetches current versions from official APIs
- Modular template system for stacks and services

## Implementation Workflow avec Debug Checkpoints

### 1. Analyze Request & Research Stack + Hints

**Natural Language Processing:**
```text
Input: "Python Django with PostgreSQL in ./docker directory"
→ Stack: Python + Django  
→ Database: PostgreSQL
→ Directory: ./docker/
→ Inferred needs: Web framework + ORM + Database + Testing + Linting
```

**AI-Driven Research (Tech-Adaptive Sources) + Fallback Hints:**
- WebSearch: "Django 2024 best practices development setup site:djangoproject.com"
  💡 **HINT OFFLINE:** If WebSearch fails → use versions in `.claude/templates/init-dev/defaults/django.json`
- WebSearch: "Python Django recommended linters 2024" + PyPI trends analysis
  💡 **HINT ALTERNATIVE:** If uncertain → use standard stack: black + flake8 + mypy
- WebSearch: "Django testing tools pytest vs unittest"
  💡 **HINT RESSOURCE:** Benchmark comparatif: https://pytest-benchmark.readthedocs.io/
- Tech-specific version detection: python.org + PyPI + Docker Hub python:x.x-slim
  💡 **HINT DEBUG:** If versions incompatible → check compatibility matrix on official docs

**Template Cherry-Picking + Hints:**
- Select from `.claude/templates/init-dev/stacks/python/`
- Check `.claude/templates/init-dev/services/postgres.yml`
- Adapt `.claude/templates/init-dev/common/Makefile` for Django-specific commands

💡 **HINT DEBUG:** If template missing → create from `.claude/templates/init-dev/stacks/_generic/`
💡 **HINT INSPIRATION:** Templates communautaires: awesome-compose, docker-library samples

### 2. Generate Stack-Specific Configuration + Debug Checkpoints

**AI Decision Making + Debug Verification:**
- Based on research, select optimal linters: `black`, `flake8`, `mypy`, `isort`
  💡 **HINT:** Si linters posent problème → désactiver dans .flake8, mypy.ini temporairement
- Choose testing framework: `pytest` (most popular in 2024)
  💡 **HINT ALTERNATIVE:** If pytest complex → native Django unittest also valid
- Determine Django version compatibility with Python version
  💡 **HINT COMPATIBILITY:** Check matrix: https://docs.djangoproject.com/en/stable/releases/
- Select appropriate database client and ORM migrations strategy
  💡 **HINT:** If migration fails → check DATABASE_URL format in .env
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

### 3. Create DOH-Compliant Stack + Validation Checkpoints

**Essential Components (Always) + Debug Hints:**
- ✅ Docker Compose with Traefik routing
  💡 **HINT:** If Traefik not accessible → check ports 8080/443 free + firewall
  💡 **HINT LOGS:** Logs Traefik dans `./var/log/traefik/` pour debugging routing
- ✅ SSL certificates via mkcert 
  💡 **HINT:** If certificates invalid → `mkcert -install` then `make ssl-setup`
- ✅ UID/GID permission matching
  💡 **HINT:** If permission denied → export UID && export GID=$(id -g) before commands
- ✅ Multi-project domain pattern: `app.{project}.localhost`
  💡 **HINT:** If domains don't work → use direct http://localhost + ports
- ✅ Makefile with `dev`, `sh`, `hello-world` targets
  💡 **HINT:** If make fails → install make: apt install make or brew install make
- ✅ Working Hello World endpoint + console command
  💡 **HINT:** If Hello World fails → detailed logs: make logs or docker compose logs app
  💡 **HINT LOGS:** Also check `./var/log/app/` and `./var/log/traefik/` for routing

**Stack-Specific Components + Debug Hints:**
- ✅ Linter container with discovered best-practice tools
  💡 **HINT:** If linter fails → start container: `docker compose --profile tools up -d linter`
- ✅ Testing framework setup with sample test
  💡 **HINT:** If tests fail → check test DB config in .env.test
- ✅ Framework-specific dependencies (requirements.txt, package.json, etc.)
  💡 **HINT:** If dependencies broken → `make clean-deps && make dev-setup`
- ✅ Database service with persistent volumes
  💡 **HINT:** If DB connection fails → check `./var/log/mysql/` or `./var/log/postgres/`
- ✅ Dotenv configuration with security practices
  💡 **HINT:** If env vars not loaded → restart containers after .env changes
- ✅ **Hello World Console Command** - CLI validation tool
  💡 **HINT:** If command fails → `make sh` then test manually in container
- ✅ **Hello World Web Endpoint** - HTTP server validation
  💡 **HINT:** If 404/500 → check routing + logs in `./var/log/app/`
- ✅ **Supervisord Integration** - Single container for web + workers + daemons
  💡 **HINT:** If process crashes → `supervisorctl status` + logs in `./var/log/supervisor/`

**Directory Structure Created (Container-Organized):**
```
Project Root:
├── docker-compose.yml       # Main orchestration (ALWAYS at root)
├── docker-compose.env       # Environment config (ALWAYS at root)
├── Makefile                 # Development commands (at root)
├── ./docker/                # User-specified container configs directory
│   ├── scripts/             # Shared scripts for all containers
│   │   └── install-deps.sh  # Dependency installer (shared)
│   ├── app/                 # Main application container (MANDATORY)
│   │   ├── Dockerfile       # App container definition
│   │   └── supervisord.conf # Process management config
│   ├── linter/              # Linter container (profile-based)
│   │   └── Dockerfile       # Linter tools container
│   ├── traefik/             # Reverse proxy container
│   │   ├── traefik.yml      # Traefik configuration
│   │   └── certs/           # SSL certificates (gitignored)
│   └── mariadb/             # Database container (when applicable)
│       ├── init/            # Initialization scripts
│       └── conf.d/          # Custom configuration
└── var/                     # Runtime data at root (gitignored)
    ├── data/                # Persistent data volumes
    │   └── mariadb/         # Database data
    └── log/                 # Application logs
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

## Why AI-Driven Approach? + Hints Pour Comprendre les Échecs

**Not Scriptable Because + Debug Reality:**
- Stack-specific best practices evolve rapidly
  💡 **HINT:** If best practices outdated → check source dates + force update
- Linting tools and versions change frequently  
  💡 **HINT:** Si linters incompatibles → pins version exactes dans requirements
- Framework-specific patterns vary significantly
  💡 **HINT:** If pattern inconsistent → priority to official framework docs
- User preferences (directory structure, tooling) need flexibility
  💡 **HINT:** If structure problematic → adapt with ln -s or refactor paths
- Current industry trends require real-time research
  💡 **HINT OFFLINE:** If no internet → use defaults.json + manual update
- **Each technology has different official sources** (php.net, python.org, nodejs.org, etc.)
  💡 **HINT:** If sources inaccessible → use alternatives: GitHub trends, Docker Hub

**Mode-Specific Behavior:**
- **Interactive Mode:** WebSearch + user confirmation for ambiguities + **MANDATORY WAIT for user approval**
- **Non-Interactive Mode:** Explicit specifications required, abort with explanation if unclear

**🚨 CRITICAL INTERACTIVE MODE RULES:**
1. **ALWAYS STOP** after showing brainstormed configuration
2. **NEVER PROCEED** without explicit user confirmation (y/yes)
3. **DEFAULT TO ABORT** if user doesn't explicitly approve (N is default)
4. **SUPPORT MODIFICATIONS** - user can request changes to proposed stack
5. **HANDLE CONFLICTS** - ask user about existing files before overwriting

**AI Advantages + Debug Reality:**
- 🔍 Real-time web research for current best practices
  💡 **HINT:** If search fails → fallback to local cache + stable versions
- 🧠 Context-aware decision making based on stack analysis
  💡 **HINT:** If decisions inconsistent → manual override possible via options
- 🎯 Intelligent template cherry-picking and adaptation
  💡 **HINT:** If template inadequate → modify in `.claude/templates/` for reuse
- 💡 Dynamic version detection and compatibility checking
  💡 **HINT:** If versions incompatible → force specific versions in description
- 🛠️ Custom Makefile generation with stack-appropriate commands
  💡 **HINT:** If Makefile bug → compare with `.claude/templates/common/Makefile`
- ✅ **Self-validation via Hello World testing** - never declares success until working
  💡 **HINT:** If validation fails 3 times → generate detailed error report

## Testing Strategy - Isolated Test Environment + Debug Patterns

### Environment Variable Injection Pattern
**The stack templates follow DOH testing principles + Debug Hints:**

1. **Container Level** - Inject test environment variable to app container
   💡 **HINT:** If env var not injected → check `environment:` section in docker-compose.yml
2. **Dotenv Level** - Application dotenv system handles environment routing  
   💡 **HINT:** If routing fails → check cascade .env → .env.test in app
3. **Makefile Level** - Provide convenient test commands with proper env vars
   💡 **HINT:** If tests fail → test manually: `docker compose exec -e APP_ENV=testing app pytest`

**Stack-Specific Test Variables:**
```bash
Laravel:        APP_ENV=testing          # Routes to .env.testing
Symfony:        APP_ENV=test             # Routes to .env.test  
Django/Python:  DJANGO_SETTINGS_MODULE  # Routes to settings.test
Rails/Ruby:     RAILS_ENV=test           # Routes to test environment  
Node.js:        NODE_ENV=test            # Routes to test config
```

**Generated Files + Debug Locations:**
- **`.env.test`** template with test-optimized configuration
  💡 **HINT:** If test config weird → compare with .env to understand overrides
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
- **Separate shells:** `docker compose run` for isolated debugging sessions
- **Inspector tools:** Real-time task and worker monitoring

**AI Self-Validation Process + Debug Escalation (3 attempts max):**
1. **Generate stack files** (including supervisord.conf if workers detected)
   💡 **HINT:** If generation fails → check templates source + write permissions
2. **Run `make dev`** 
   💡 **HINT:** If make dev fails → `export UID && export GID=$(id -g)` then retry
3. **Test console Hello World** → If fails: analyze error, debug, retry
   💡 **HINT:** Logs console dans `./var/log/app/django.log` ou framework équivalent
4. **Test web Hello World** → If fails: analyze error, debug, retry  
   💡 **HINT:** Check routing Traefik + certificats SSL + firewall ports 80/443
5. **Test Hello-DB** (if database) → If fails: analyze error, debug, retry
   💡 **HINT:** Connection string + user/password + database existence + network Docker
6. **Test Hello-Workers** (if workers) → supervisorctl status, worker health checks
   💡 **HINT:** Process status + queue connectivity + worker logs dans `./var/log/supervisor/`
7. **Final Status + Recovery Options:**
   - **Interactive:** Ask user for help if 3 attempts fail + suggest manual fixes
   - **Non-Interactive:** Abort with detailed error file → `./DOH_DEBUG_REPORT.md`
   💡 **HINT ESCALATION:** If 3 failures → generate minimal template + detailed debug guide

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

## Troubleshooting + Debug Hints Complets

**Permission Issues:**
- Check UID/GID mapping in docker-compose.yml
- Ensure ./var/ directories are writable
- 💡 **HINT:** `export UID && export GID=$(id -g)` before all Docker commands

**SSL Certificate Issues:**
- Run `mkcert -install` first
- Copy certificates to ./docker/certs/
- 💡 **HINT:** If certificates expire → `make ssl-setup` to regenerate
- 💡 **HINT ALTERNATIVE:** Utiliser http://localhost:8080 sans HTTPS

**Database Connection Issues:**  
- Check DATABASE_URL in .env
- Ensure database container is running: `docker compose ps`
- 💡 **HINT LOGS:** Check `./var/log/mysql/` ou `./var/log/postgres/` pour erreurs DB
- 💡 **HINT CONNECTION:** Tester: `docker compose exec db mysql -u root -p` (MySQL)

**Worker Process Issues:**
- Check supervisord status: `make sh` then `supervisorctl status`
- Debug single worker: `make worker-debug`
- Check worker logs: `make logs-workers`
- 💡 **HINT PROCESS:** If worker crashes → `supervisorctl restart workers:*`
- 💡 **HINT DEBUG:** Logs supervisord dans `./var/log/supervisor/`

**Common Debug Paths:**
- App logs: `./var/log/app/`
- Traefik logs: `./var/log/traefik/`
- Database logs: `./var/log/mysql/` ou `./var/log/postgres/`
- Worker logs: `./var/log/supervisor/`
- Web server logs: `./var/log/nginx/` (si applicable)

**Quick Debug Commands:**
- `make logs` → All logs in real-time
- `make sh` → Shell dans container principal  
- `docker compose ps` → Status de tous les services
- `docker compose exec app supervisorctl status` → Status des process

---
*Generated by DOH init-dev on {{TIMESTAMP}}*
*Framework: {{FRAMEWORK}} {{VERSION}} | Database: {{DATABASE}} {{VERSION}}*
```

### 4. Final Synthesis Report + Next Steps Debugging

**After successful creation (ou échec avec debug guide), display:**
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
• ./docker-compose.yml - Main orchestration at project root
• ./docker/Dockerfile + Dockerfile.linter - App + linting containers  
• ./docker/Makefile - Enhanced development commands
• ./requirements.txt - Python dependencies
• ./src/hello_world.py - Hello World implementations
• ./INITDEV.md - Quick start guide

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

📝 **Next Steps + Debug Checkpoints:**
1. make dev          # Start development environment
   💡 If fails → export UID && export GID=$(id -g) then retry
2. make hello-world  # Validate everything works
   💡 If fails → make logs to see errors + check INITDEV.md troubleshooting
3. make sh          # Enter main app container  
   💡 For manual debug + test components individually
4. Start coding! 🚀
   💡 Hot-reload should work, otherwise check volumes in docker-compose.yml

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

## Key Features + Debug Philosophy

### Template-Based & Up-to-Date + Fallback Robuste
- **Modular templates** from `.claude/templates/init-dev/`
  💡 **HINT:** If template missing → create from `_generic/` + adapt
- **Current versions** fetched from official APIs at runtime
  💡 **HINT OFFLINE:** If API inaccessible → use `offline-defaults.json`
- **Flexible composition** of services and stacks
  💡 **HINT:** Templates = starting point, customization expected and normal

### Linter Integration + Debug Support
- **Separate containers** for linting tools per stack
  💡 **HINT:** Si linter fail → `docker compose --profile tools up -d linter`
- **Version isolation** - no conflicts with main application
  💡 **HINT:** If version conflicts → pin exact versions in Dockerfile.linter
- **Team standardization** - same tools for everyone
  💡 **HINT CUSTOM:** Override linters dans `.claude/templates/custom/linters.yml`
- **Profiles support** - start linters only when needed
  💡 **HINT PERFORMANCE:** `make lint-start` seulement quand nécessaire

### Multi-Project Support + Conflict Resolution
- **Domain isolation** via `{service}.{project}.localhost`
  💡 **HINT:** If domains don't work → use direct ports http://localhost:8000
- **SSL certificates** with mkcert wildcards
  💡 **HINT:** If certificates cause problems → disable HTTPS temporarily
- **Configurable ports** - Traefik ports via environment variables to avoid dev machine conflicts
  💡 **HINT PORTS:** Modifier EXTERNAL_HTTP_PORT/EXTERNAL_HTTPS_PORT si occupés
- **Project namespacing** in all configurations
  💡 **HINT:** PROJECT_NAME auto-détecté depuis nom directory

### Developer Experience + Recovery Patterns
- **One command setup** - `make dev-setup && make dev`
  💡 **HINT:** If setup fails → debug step by step with `make dev-setup` then `make dev`
- **Comprehensive Makefile** with linting, database, and dev commands
  💡 **HINT:** `make help` pour voir toutes les commandes disponibles
- **Quick start guide** - INITDEV.md with stack-specific examples
  💡 **HINT:** INITDEV.md = reference complète pour troubleshooting
- **Template documentation** - clear extension points
  💡 **HINT EXTEND:** Templates dans `.claude/templates/` modifiables pour besoins custom

### 🧠 Debug Philosophy Intégrée
**"AI will fail, the dev will need to debug" - we help proactively:**
- Hints automatiques dans tous les fichiers générés
- Logs centralisés dans `./var/log/`
- Commandes de debug rapides dans Makefile
- Documentation troubleshooting complète
- Escalation guidée si 3 tentatives AI échouent
- Templates minimal + guide debug si tout échoue

💡 **MÉTA-HINT:** Ce HOWTO lui-même évolue - contribuer améliorations dans `.claude/commands/doh/init-dev.md`