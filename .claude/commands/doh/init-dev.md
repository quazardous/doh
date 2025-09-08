---
allowed-tools: Bash, Glob, Grep, LS, Read, Write, Edit, MultiEdit, WebFetch
---

# Initialize Development Stack - HOWTO Amélioré pour Dev Docker Efficace

Guide AI-assisté pour créer rapidement un environnement Docker de développement moderne et pragmatique. Combine analyse de stack intelligente + templates DOH + recherche web des best practices actuelles + validation complète.

> **🎯 OBJECTIF:** Aller plus vite vers une dev Docker efficace avec de bons patterns architecturaux
> 
> **🧠 PHILOSOPHIE:** Templates "kitchen" + hints de debug + AI auto-corrective pour réussir même si l'IA ne fait pas parfait du premier coup

## Usage
```
/doh:init-dev <natural language stack description>
/doh:init-dev "Python Django with PostgreSQL in ./docker directory"  
/doh:init-dev "Node.js React fullstack with MySQL and Redis"
/doh:init-dev "PHP Laravel API with PostgreSQL and background jobs"
/doh:init-dev "Python FastAPI microservice with MongoDB"
```

## Approche AI + Hints de Debug

⚡ **Command AI-piloté** avec système de hints intégrés pour réussir même si l'IA échoue au premier coup:

### 🗯 Système de Debug Hints (Nouveauté)

**Philosophy:** Le développeur va **FORCÉMENT** devoir débugger/ajuster, donc on anticipe les problèmes courants:

```bash
# Hints automatiquement ajoutés dans les fichiers générés:
# HINT: If permission denied -> check UID/GID in docker-compose.yml
# HINT: If build fails -> try 'make clean && make rebuild'
# HINT: If database connection fails -> check .env DATABASE_URL format
# HINT: Alternative stack configs at https://github.com/laradock/laradock
```

**Types de Hints Intégrés:**
- 🔧 **Hints de Dépannage:** Problèmes Docker courants (permissions, ports, SSL)
- 🔄 **Hints d'Alternatives:** Liens vers autres approches si pattern DOH ne convient pas
- 📚 **Hints de Ressources:** Documentation officielle, exemples communautaires
- 🚀 **Hints d'Optimisation:** Améliorations performance, sécurité, workflows

### 🎯 AI Auto-Correctif

L'IA teste ses propres générations et se corrige automatiquement:

### 1. Stack Analysis avec Debug Hints

**Manual Mode** (`/doh:init-dev "Python Django..."`):
- Parse natural language description  
- Identify components from user input
- 💡 **HINT:** Si description ambiguë → WebSearch "{{framework}} development setup 2024" pour clarifier
- 💡 **HINT ALTERNATIVE:** Si pas satisfait → essayer Detection Mode: `/doh:init-dev --detect`

**Detection Mode** (`/doh:init-dev --detect`):
- **File Analysis:** Examine existing project files for technology indicators
  ```text
  package.json → Node.js/JavaScript stack
  requirements.txt → Python stack  
  composer.json → PHP stack
  Cargo.toml → Rust stack
  go.mod → Go stack
  ```
  💡 **HINT:** Si détection échoue → vérifier extensions: `.py`, `.js`, `.php` dans `/src` ou `/app`
  💡 **HINT RESSOURCE:** Documentation patterns https://12factor.net/config
  
- **Dependency Analysis:** Parse dependency files for framework detection
  ```text
  Django in requirements.txt → Django framework
  express in package.json → Express.js framework
  laravel/framework in composer.json → Laravel framework
  ```
  💡 **HINT DEBUG:** Si framework pas détecté → check versions dans requirements.txt/package.json
  💡 **HINT ALTERNATIVE:** Override manuel: `/doh:init-dev "Force Django avec PostgreSQL"`
  
- **README Analysis:** Extract technology mentions and setup instructions
- **Existing Docker Analysis:** Check current docker-compose.yml for services
- **Database Detection:** Look for database connection configs and migrations
  💡 **HINT:** Si DB pas détectée → regarder dans `settings.py`, `config/database.php`, `.env.example`

### 2. Cherry-Pick Templates avec Fallback Hints
- Analyze `.claude/templates/init-dev/` for relevant inspiration
- Select appropriate base templates (common/, stacks/, services/)
- Adapt template patterns to detected/requested stack

💡 **HINT ARCHITECTURE:** Templates = "kitchen" de départ, PAS solution finale
💡 **HINT DEBUG:** Si template inadapté → check `.claude/templates/init-dev/stacks/{{your-framework}}/` pour alternatives
💡 **HINT RESSOURCE:** Inspiration externe: https://github.com/laradock/laradock, https://github.com/dunglas/symfony-docker
💡 **HINT CUSTOM:** Créer son template dans `.claude/templates/init-dev/stacks/custom/` si besoin récurrent

### 3. Research + Hints Ressources (Tech-Adaptive)
- **Mode Interactif:** WebSearch with tech-specific sources for latest recommendations
- **Mode Non-Interactif:** Use explicitly specified versions and tools only
- **Tech-Specific Sources:** Adapt research to technology ecosystem

💡 **HINT PERFORMANCE:** Si WebSearch lent → utiliser cache local ou versions template par défaut
💡 **HINT OFFLINE:** Si pas d'internet → utiliser `.claude/templates/init-dev/offline-defaults.json`
💡 **HINT OVERRIDE:** Forcer version spécifique: `"Python 3.11 Django 4.2 avec PostgreSQL 14"`

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

💡 **HINT PERMISSIONS:** Si erreurs 403/permisions → export UID && export GID=$(id -g) avant docker compose
💡 **HINT PORTS:** Si conflit ports → modifier EXTERNAL_HTTP_PORT/EXTERNAL_HTTPS_PORT dans docker-compose.env
💡 **HINT SSL:** Si certificats invalides → rm -rf docker/certs/* && make ssl-setup
💡 **HINT TROUBLESHOOT:** Logs complets: make logs ou docker compose logs -f {{service}}

### Directory Customization
- User can specify directory: "in ./docker" → creates files in `./docker/`
- Default: `./docker-dev/` (DOH standard)
- Respects user preference while maintaining DOH patterns

## Core Philosophy + Patterns de Debug

### COPY vs Volume Mount Rules + Debug Hints (STRICT)

**🚨 COPY FORBIDDEN for:**
- Application code (`/app/*` directory)
- User-level configs (supervisord, workers, app configs)
- Frontend assets (CSS, JS, HTML)
- Environment files (`.env`, `settings.py`)
- Anything owned by non-root users in container

💡 **HINT DEBUG COPY:** Si changements code pas visibles → vérifier volumes dans docker-compose.yml
💡 **HINT ALTERNATIVE:** Si volume mount problématique → essayer bind mounts ou named volumes
💡 **HINT PERFORMANCE:** Si volumes lents sur Windows → essayer Docker Desktop WSL2

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
  💡 **HINT:** Si build lent → check .dockerignore pour exclure node_modules, .git, var/
- **Fast dependency updates** - `make update-deps` without container rebuild
  💡 **HINT:** Si update échoue → essayer `make clean-deps` puis `make dev-setup`
- **Instant code changes** - Volume mounts for immediate feedback
  💡 **HINT:** Si pas de hot-reload → check que le framework supporte (webpack-dev-server, etc.)
- **Better caching** - System tools vs application dependencies separation  
- **Flexible workflows** - `make dev`, `make update-deps`, `make clean-deps`
  💡 **HINT:** Si commandes échouent → check que containers sont démarrés: `docker compose ps`

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
# ✅ MANDATORY for all application code
volumes:
  - ..:/app                                                     # ALL application code
  - ./docker/supervisord.conf:/etc/supervisor/supervisord.conf:ro  # user-level configs
  - ./docker/data/mariadb:/var/lib/mysql                      # data in user-specified directory
  
  # Optional: Nginx configs (can be commented for flexibility)
  # - ./docker/nginx/myapp.conf.template:/etc/nginx/templates/myapp.conf.template:ro
```

### Docker-Focused & Pragmatic + Debugging
- **Docker as standard** unless explicitly contraindicated
  💡 **HINT:** Si Docker pose problème → alternatives: Vagrant, lima, podman, colima
- **Volume mounts mandatory** - COPY forbidden for application code and user-level configs
  💡 **HINT:** Si volumes ne marchent pas → check Docker Desktop file sharing settings
- **Single app container** - Embed frontend build in backend container, avoid over-containerization
  💡 **HINT:** Si trop complexe → exemple containers séparés: https://github.com/laradock/laradock
- **Multi-project friendly** - `{service}.{project}.localhost` domains with `dev.project={PROJECT_NAME}` labels
  💡 **HINT:** Si domaines marchent pas → check /etc/hosts ou utiliser http://localhost:8080
- **Data in user directory** - Database volumes in user-specified folder (./docker/data/ ou ./docker-dev/data/)
  💡 **HINT:** Si data perdue → check que volumes pointent vers bonne directory dans docker-compose.yml
- **Linting containers** - Separate linter containers to avoid version conflicts (profile-based)
  💡 **HINT:** Si linter échoue → démarrer avec: `docker compose --profile tools up -d linter`

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
  💡 **HINT OFFLINE:** Si WebSearch échoue → utiliser versions dans `.claude/templates/init-dev/defaults/django.json`
- WebSearch: "Python Django recommended linters 2024" + PyPI trends analysis
  💡 **HINT ALTERNATIVE:** Si incertain → utiliser stack standard: black + flake8 + mypy
- WebSearch: "Django testing tools pytest vs unittest"
  💡 **HINT RESSOURCE:** Benchmark comparatif: https://pytest-benchmark.readthedocs.io/
- Tech-specific version detection: python.org + PyPI + Docker Hub python:x.x-slim
  💡 **HINT DEBUG:** Si versions incompatibles → check compatibility matrix sur docs officielles

**Template Cherry-Picking + Hints:**
- Select from `.claude/templates/init-dev/stacks/python/`
- Check `.claude/templates/init-dev/services/postgres.yml`
- Adapt `.claude/templates/init-dev/common/Makefile` for Django-specific commands

💡 **HINT DEBUG:** Si template manque → créer depuis `.claude/templates/init-dev/stacks/_generic/`
💡 **HINT INSPIRATION:** Templates communautaires: awesome-compose, docker-library samples

### 2. Generate Stack-Specific Configuration + Debug Checkpoints

**AI Decision Making + Debug Verification:**
- Based on research, select optimal linters: `black`, `flake8`, `mypy`, `isort`
  💡 **HINT:** Si linters posent problème → désactiver dans .flake8, mypy.ini temporairement
- Choose testing framework: `pytest` (most popular in 2024)
  💡 **HINT ALTERNATIVE:** Si pytest complexe → unittest native Django aussi valide
- Determine Django version compatibility with Python version
  💡 **HINT COMPATIBILITY:** Check matrix: https://docs.djangoproject.com/en/stable/releases/
- Select appropriate database client and ORM migrations strategy
  💡 **HINT:** Si migration échoue → vérifier DATABASE_URL format dans .env
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
  💡 **HINT:** Si Traefik pas accessible → check ports 8080/443 libres + firewall
  💡 **HINT LOGS:** Logs Traefik dans `./var/log/traefik/` pour debugging routing
- ✅ SSL certificates via mkcert 
  💡 **HINT:** Si certificats invalides → `mkcert -install` puis `make ssl-setup`
- ✅ UID/GID permission matching
  💡 **HINT:** Si permission denied → export UID && export GID=$(id -g) avant commandes
- ✅ Multi-project domain pattern: `app.{project}.localhost`
  💡 **HINT:** Si domaines marchent pas → utiliser http://localhost direct + ports
- ✅ Makefile with `dev`, `sh`, `hello-world` targets
  💡 **HINT:** Si make échoue → installer make: apt install make ou brew install make
- ✅ Working Hello World endpoint + console command
  💡 **HINT:** Si Hello World échoue → logs détaillés: make logs ou docker compose logs app
  💡 **HINT LOGS:** Check aussi `./var/log/app/` et `./var/log/traefik/` pour routing

**Stack-Specific Components + Debug Hints:**
- ✅ Linter container with discovered best-practice tools
  💡 **HINT:** Si linter fail → start container: `docker compose --profile tools up -d linter`
- ✅ Testing framework setup with sample test
  💡 **HINT:** Si tests échouent → check test DB config dans .env.test
- ✅ Framework-specific dependencies (requirements.txt, package.json, etc.)
  💡 **HINT:** Si dépendances cassées → `make clean-deps && make dev-setup`
- ✅ Database service with persistent volumes
  💡 **HINT:** Si DB connection fail → check `./var/log/mysql/` ou `./var/log/postgres/`
- ✅ Dotenv configuration with security practices
  💡 **HINT:** Si env vars pas prises → restart containers après changement .env
- ✅ **Hello World Console Command** - CLI validation tool
  💡 **HINT:** Si commande fail → `make sh` puis tester manuellement dans container
- ✅ **Hello World Web Endpoint** - HTTP server validation
  💡 **HINT:** Si 404/500 → check routing + logs dans `./var/log/app/`
- ✅ **Supervisord Integration** - Single container for web + workers + daemons
  💡 **HINT:** Si process crash → `supervisorctl status` + logs dans `./var/log/supervisor/`

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
   • ./docker/docker-compose.yml → Single app container + services (NO separate vue container)
   • ./docker/docker-compose.env-docker → Project config with proper volume mounts
   • ./docker/Dockerfile → Python 3.12-slim with Node.js (NO COPY of app code)
   • ./docker/Dockerfile.linter → Separate container with black/flake8/mypy/isort
   • ./docker/supervisord.conf → Web server + Celery workers configuration (volume mounted)
   • ./docker/Makefile → Enhanced with Django + Vue + worker commands + hello-world target
   • ./requirements.txt → Django 5.2 + mysqlclient + celery + pytest-django + linters
   • ./docker/traefik.yml-docker → HTTPS routing configuration
   • ./src/hello_world.py → Django Hello World view + management command
   • ./manage.py hello → Console Hello World command + Celery status check
   • ./INSTADEV.md → Quick start guide with volume mount architecture
   • ./.env.test → Test configuration (SQLite, in-memory cache, sync queues)
   
   Volume Strategy:
   • ..:/app → ALL application code (Django + Vue.js)
   • ./docker/data/mariadb:/var/lib/mysql → Data in user-specified directory
   • ./docker/supervisord.conf:/etc/supervisor/supervisord.conf:ro → Config volume
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
  💡 **HINT:** Si best practices obsolètes → check date des sources + force update
- Linting tools and versions change frequently  
  💡 **HINT:** Si linters incompatibles → pins version exactes dans requirements
- Framework-specific patterns vary significantly
  💡 **HINT:** Si pattern incohérent → priorité à la doc officielle du framework
- User preferences (directory structure, tooling) need flexibility
  💡 **HINT:** Si structure gêne → adapter avec ln -s ou refactor paths
- Current industry trends require real-time research
  💡 **HINT OFFLINE:** Si pas d'internet → utiliser defaults.json + mise à jour manuelle
- **Each technology has different official sources** (php.net, python.org, nodejs.org, etc.)
  💡 **HINT:** Si sources inaccessibles → utiliser alternatives: GitHub trends, Docker Hub

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
  💡 **HINT:** Si recherche échoue → fallback sur cache local + versions stable
- 🧠 Context-aware decision making based on stack analysis
  💡 **HINT:** Si décisions incohérentes → override manuel possible via options
- 🎯 Intelligent template cherry-picking and adaptation
  💡 **HINT:** Si template inadapté → modifier dans `.claude/templates/` pour réutilisation
- 💡 Dynamic version detection and compatibility checking
  💡 **HINT:** Si versions incompatibles → forcer versions spécifiques dans description
- 🛠️ Custom Makefile generation with stack-appropriate commands
  💡 **HINT:** Si Makefile bug → comparer avec `.claude/templates/common/Makefile`
- ✅ **Self-validation via Hello World testing** - never declares success until working
  💡 **HINT:** Si validation échoue 3 fois → générer rapport d'erreur détaillé

## Testing Strategy - Isolated Test Environment + Debug Patterns

### Environment Variable Injection Pattern
**The stack templates follow DOH testing principles + Debug Hints:**

1. **Container Level** - Inject test environment variable to app container
   💡 **HINT:** Si env var pas injectée → check `environment:` section dans docker-compose.yml
2. **Dotenv Level** - Application dotenv system handles environment routing  
   💡 **HINT:** Si routing fail → vérifier cascade .env → .env.test dans app
3. **Makefile Level** - Provide convenient test commands with proper env vars
   💡 **HINT:** Si tests fail → tester manuellement: `docker compose exec -e APP_ENV=testing app pytest`

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
  💡 **HINT:** Si config test bizarre → comparer avec .env pour comprendre overrides
- **Makefile** test commands with environment injection
  💡 **HINT:** Si commande test échoue → run manuellement pour voir erreur exacte
- **Test isolation** via in-memory/SQLite databases
  💡 **HINT:** Si isolation cassée → check que test DB != dev DB dans configs
- **Coverage reports** in `./var/coverage/`
  💡 **HINT:** Si pas de coverage → check que `./var/` writable + coverage installé

## Final Output & Testing

### 1. Hello World Implementation (AI Success Criteria)

**🎯 CRITICAL: Stack creation is NOT complete until ALL Hello Worlds work!**

💡 **HINT DEBUG HELLO WORLD:** Si Hello World échoue, suivre cette séquence de debug:
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
   💡 **HINT:** Si génération échoue → check templates source + permissions écriture
2. **Run `make dev`** 
   💡 **HINT:** Si make dev échoue → `export UID && export GID=$(id -g)` puis retry
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
   💡 **HINT ESCALATION:** Si 3 échecs → générer template minimal + guide debug détaillé

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

## Troubleshooting + Debug Hints Complets

**Permission Issues:**
- Check UID/GID mapping in docker-compose.yml
- Ensure ./var/ directories are writable
- 💡 **HINT:** `export UID && export GID=$(id -g)` avant toutes commandes Docker

**SSL Certificate Issues:**
- Run `mkcert -install` first
- Copy certificates to ./docker/certs/
- 💡 **HINT:** Si certificats expirent → `make ssl-setup` pour régénérer
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
- 💡 **HINT PROCESS:** Si worker crash → `supervisorctl restart workers:*`
- 💡 **HINT DEBUG:** Logs supervisord dans `./var/log/supervisor/`

**Common Debug Paths:**
- App logs: `./var/log/app/`
- Traefik logs: `./var/log/traefik/`
- Database logs: `./var/log/mysql/` ou `./var/log/postgres/`
- Worker logs: `./var/log/supervisor/`
- Web server logs: `./var/log/nginx/` (si applicable)

**Quick Debug Commands:**
- `make logs` → Tous les logs en temps réel
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

📝 **Next Steps + Debug Checkpoints:**
1. make dev          # Start development environment
   💡 Si échoue → export UID && export GID=$(id -g) puis retry
2. make hello-world  # Validate everything works
   💡 Si échoue → make logs pour voir erreurs + check INITDEV.md troubleshooting
3. make sh          # Enter main app container  
   💡 Pour debug manuel + tester composants individuellement
4. Start coding! 🚀
   💡 Hot-reload doit marcher, sinon check volumes dans docker-compose.yml

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
  💡 **HINT:** Si template manque → créer depuis `_generic/` + adapter
- **Current versions** fetched from official APIs at runtime
  💡 **HINT OFFLINE:** Si API inaccessible → utiliser `offline-defaults.json`
- **Flexible composition** of services and stacks
  💡 **HINT:** Templates = point de départ, customisation attendue et normale

### Linter Integration + Debug Support
- **Separate containers** for linting tools per stack
  💡 **HINT:** Si linter fail → `docker compose --profile tools up -d linter`
- **Version isolation** - no conflicts with main application
  💡 **HINT:** Si conflit versions → pin versions exactes dans Dockerfile.linter
- **Team standardization** - same tools for everyone
  💡 **HINT CUSTOM:** Override linters dans `.claude/templates/custom/linters.yml`
- **Profiles support** - start linters only when needed
  💡 **HINT PERFORMANCE:** `make lint-start` seulement quand nécessaire

### Multi-Project Support + Conflict Resolution
- **Domain isolation** via `{service}.{project}.localhost`
  💡 **HINT:** Si domaines marchent pas → utiliser ports directs http://localhost:8000
- **SSL certificates** with mkcert wildcards
  💡 **HINT:** Si certificats posent problème → désactiver HTTPS temporairement
- **Configurable ports** - Traefik ports via environment variables to avoid dev machine conflicts
  💡 **HINT PORTS:** Modifier EXTERNAL_HTTP_PORT/EXTERNAL_HTTPS_PORT si occupés
- **Project namespacing** in all configurations
  💡 **HINT:** PROJECT_NAME auto-détecté depuis nom directory

### Developer Experience + Recovery Patterns
- **One command setup** - `make dev-setup && make dev`
  💡 **HINT:** Si setup échoue → debug étape par étape avec `make dev-setup` puis `make dev`
- **Comprehensive Makefile** with linting, database, and dev commands
  💡 **HINT:** `make help` pour voir toutes les commandes disponibles
- **Quick start guide** - INITDEV.md with stack-specific examples
  💡 **HINT:** INITDEV.md = reference complète pour troubleshooting
- **Template documentation** - clear extension points
  💡 **HINT EXTEND:** Templates dans `.claude/templates/` modifiables pour besoins custom

### 🧠 Debug Philosophy Intégrée
**"L'IA va échouer, le dev va devoir debugger" - on l'aide proactivement:**
- Hints automatiques dans tous les fichiers générés
- Logs centralisés dans `./var/log/`
- Commandes de debug rapides dans Makefile
- Documentation troubleshooting complète
- Escalation guidée si 3 tentatives AI échouent
- Templates minimal + guide debug si tout échoue

💡 **MÉTA-HINT:** Ce HOWTO lui-même évolue - contribuer améliorations dans `.claude/commands/doh/init-dev.md`