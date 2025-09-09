# Framework Specifics - Complete Reference for DOH init-dev
# =================================================================
# 
# 🚨 MANDATORY READING: /doh:init-dev command MUST read this file for:
# - Framework detection patterns (file analysis, dependency analysis)
# - Technology-specific implementation details 
# - CLI tools and command patterns per framework
# - Hello-doh implementation requirements
# 
# L'IA DOIT consulter ce fichier avant de générer des stacks pour comprendre
# les conventions, outils, et patterns spécifiques à chaque technologie

# =================================================================
# FRAMEWORK DETECTION PATTERNS - MANDATORY FOR --detect MODE
# =================================================================

## Base Image Strategy by Technology Stack

**📊 STRATEGY BY DETECTED TECHNOLOGY:**

### PHP (Laravel/Symfony)
- Frontend détecté → `FROM composer:2 + FROM node:20 → php:8.3-fpm`
- Backend seul → `FROM composer:2 → php:8.3-fpm`

### Python (Django/FastAPI)  
- Frontend détecté → `FROM node:20 → python:3.12-slim`
- Backend seul → `FROM python:3.12-slim`

### Node.js (Express/Nest)
- Pur → `FROM node:20-alpine` (pas de multi-stage nécessaire)

### Go
- Frontend détecté → `FROM node:20 → golang:1.21-alpine`
- Backend seul → `FROM golang:1.21-alpine`

### Rust
- Frontend détecté → `FROM node:20 → rust:1.70-slim`
- Backend seul → `FROM rust:1.70-slim`

### Ruby (Rails)
- Frontend détecté → `FROM node:20 → ruby:3.2-slim`
- Backend seul → `FROM ruby:3.2-slim`

### Java (Spring)
- Frontend détecté → `FROM node:20 → openjdk:21-slim`
- Backend seul → `FROM openjdk:21-slim`

### .NET
- Frontend détecté → `FROM node:20 → mcr.microsoft.com/dotnet/sdk:8.0`
- Backend seul → `FROM mcr.microsoft.com/dotnet/sdk:8.0`

**🚨 RULE:** AI selects tools according to detected technology matrix

### Multi-stage Strategy Rules
- **AI Research:** WebSearch "{{framework}} docker development requirements"
- **Conditional Stages:** Créer stages seulement pour outils détectés
- **Cherry-Pick Pattern:** `COPY --from=` pour éviter bloat des base images  
- **Version Detection:** Utiliser versions officielles actuelles des images
- **System Tools:** git, sudo installés dans main stage

## Framework-Specific Frontend Variable Mapping

**Frontend Environment Variable Patterns:**

### React
- `REACT_APP_API_URL=${FRONTEND_API_URL}` - Exposed to window.process.env
- `REACT_APP_DOH_SECRET=${DOH_SECRET}` - Validation via frontend

### Vue.js
- `VUE_APP_API_URL=${FRONTEND_API_URL}` - Exposed to process.env
- `VUE_APP_DOH_SECRET=${DOH_SECRET}` - Validation via frontend

### Vite (Vue 3, React, etc.)
- `VITE_API_URL=${FRONTEND_API_URL}` - Exposed to import.meta.env
- `VITE_DOH_SECRET=${DOH_SECRET}` - Validation via frontend

### Next.js
- `NEXT_PUBLIC_API_URL=${FRONTEND_API_URL}` - Exposed to process.env
- `NEXT_PUBLIC_DOH_SECRET=${DOH_SECRET}` - Validation via frontend

### Angular
- Custom environment service injection pattern
- Build-time variable replacement in environment files

### Svelte/SvelteKit
- `VITE_API_URL=${FRONTEND_API_URL}` - Via Vite integration
- Public environment variable prefix handling

## Frontend Dotenv Implementation Patterns

### Webpack Integration
```javascript
// webpack.config.js with dotenv-webpack
const Dotenv = require('dotenv-webpack');

new Dotenv({
  path: process.env.NODE_ENV === 'test' ? './.env.test' : './.env',
  safe: false,    // Use .env.example for validation if true
  systemvars: true // Include system environment variables
})
```

### Vite Integration
```javascript  
// vite.config.js with native loadEnv
const env = loadEnv(mode, process.cwd(), '');
if (mode === 'test') {
  Object.assign(process.env, loadEnv('test', process.cwd(), ''));
}
```

### Environment Routing Strategy
1. **Single Source:** Backend `.env` / `.env.test` files contain all variables
2. **Frontend Exposure:** Build tools (webpack/vite) expose prefixed variables to browser
3. **Test Isolation:** `.env.test` overrides for both backend and frontend during testing
4. **Build-Time Injection:** Environment variables embedded during build process

# =================================================================
# FRAMEWORK DETECTION PATTERNS - MANDATORY FOR --detect MODE
# =================================================================

## File-Based Detection Patterns

### Primary Detection Files (High Confidence)
| File | Framework/Technology | Confidence |
|------|---------------------|------------|
| `package.json` | Node.js/JavaScript stack | 95% |
| `requirements.txt` | Python stack | 95% |
| `composer.json` | PHP stack | 95% |
| `Cargo.toml` | Rust stack | 95% |
| `go.mod` | Go stack | 95% |
| `Gemfile` | Ruby stack | 95% |
| `pom.xml` | Java (Maven) | 95% |
| `build.gradle` | Java (Gradle) | 95% |
| `*.csproj` / `*.sln` | .NET stack | 95% |

### Secondary Detection Files (Medium Confidence)
| File | Framework Hint | Confidence |
|------|----------------|------------|
| `manage.py` | Django (Python) | 85% |
| `artisan` | Laravel (PHP) | 85% |
| `bin/console` | Symfony (PHP) | 85% |
| `Rakefile` | Rails (Ruby) | 80% |
| `next.config.js` | Next.js (Node) | 80% |
| `vite.config.js` | Vite-based (Vue/React) | 75% |
| `nuxt.config.js` | Nuxt.js (Vue) | 80% |

### Extension-Based Fallback Detection
| Extensions | Technology | Confidence |
|------------|------------|------------|
| `.py` files | Python | 60% |
| `.js` files | JavaScript/Node.js | 60% |
| `.php` files | PHP | 70% |
| `.go` files | Go | 70% |
| `.rs` files | Rust | 80% |
| `.rb` files | Ruby | 70% |
| `.java` files | Java | 70% |
| `.cs` files | C#/.NET | 70% |

## Dependency-Based Framework Detection

### Python (requirements.txt)
| Package | Framework | Confidence |
|---------|-----------|------------|
| `Django>=` | Django | 90% |
| `Flask>=` | Flask | 90% |
| `FastAPI>=` | FastAPI | 90% |
| `fastapi` | FastAPI | 90% |
| `django-rest-framework` | Django REST | 85% |
| `celery` | Task queue (Django/Flask) | 70% |

### Node.js (package.json dependencies)
| Package | Framework | Confidence |
|---------|-----------|------------|
| `"next"` | Next.js | 90% |
| `"react"` | React | 85% |
| `"vue"` | Vue.js | 85% |
| `"@vue/cli"` | Vue.js | 90% |
| `"express"` | Express.js | 85% |
| `"@nestjs/core"` | NestJS | 90% |
| `"nuxt"` | Nuxt.js | 90% |

### PHP (composer.json)
| Package | Framework | Confidence |
|---------|-----------|------------|
| `"laravel/framework"` | Laravel | 95% |
| `"symfony/framework-bundle"` | Symfony | 95% |
| `"cakephp/cakephp"` | CakePHP | 90% |
| `"codeigniter4/framework"` | CodeIgniter | 90% |

### Ruby (Gemfile)
| Package | Framework | Confidence |
|---------|-----------|------------|
| `gem 'rails'` | Rails | 95% |
| `gem 'sinatra'` | Sinatra | 90% |

## Database Detection Patterns

### Configuration File Analysis
| File | Database Indicator | Confidence |
|------|-------------------|------------|
| `settings.py` (Django) | `DATABASES = {'ENGINE': 'django.db.backends.postgresql'}` | 90% |
| `config/database.php` (Laravel) | `'default' => 'mysql'` | 85% |
| `.env` | `DATABASE_URL=postgres://` | 80% |
| `docker-compose.yml` | Service names: postgres, mysql, mariadb | 75% |

### Dependency-Based Database Detection
| Dependency | Database | Framework Context |
|------------|----------|------------------|
| `psycopg2` | PostgreSQL | Python |
| `mysqlclient` | MySQL/MariaDB | Python |
| `mysql2` | MySQL | Node.js |
| `pg` | PostgreSQL | Node.js |
| `doctrine/orm` | Multi (usually MySQL) | PHP |

## Frontend Detection Patterns (for full-stack stacks)

### Build Tool Detection
| File | Frontend Stack | Build Tool |
|------|----------------|------------|
| `vite.config.js` | Vue.js/React | Vite |
| `webpack.config.js` | React/Vue | Webpack |
| `nuxt.config.js` | Vue.js | Nuxt |
| `next.config.js` | React | Next.js |
| `angular.json` | Angular | Angular CLI |

### Package.json Frontend Clues
| Script/Dependency | Frontend Framework |
|------------------|-------------------|
| `"dev": "vite"` | Vite (Vue/React) |
| `"dev": "next dev"` | Next.js |
| `"serve": "vue-cli-service serve"` | Vue CLI |
| `"start": "react-scripts start"` | Create React App |

## 📊 TOOL MATRIX BY TECHNOLOGY (avec CLI spécifiques)

| Technology | CLI Tool | Project Init | Management Commands | Dependency Manager | Database Tools |
|-------------|----------|--------------|--------------------|--------------------|----------------|
| **Django** | `django-admin` | `django-admin startproject myproject .` | `python manage.py migrate/shell/test` | `pip` | Django ORM |
| **Symfony** | `symfony` CLI | `symfony new myproject --version=6.4` | `php bin/console doctrine:migrate` | `composer` | Doctrine ORM |
| **Laravel** | `artisan` | `composer create-project laravel/laravel myproject` | `php artisan migrate/tinker/test` | `composer` | Eloquent ORM |
| **Rails** | `rails` | `rails new myproject` | `rails generate/db:migrate/console` | `bundler/gem` | Active Record |
| **Next.js** | `npx create-next-app` | `npx create-next-app myproject` | `npm run dev/build` | `npm/yarn/pnpm` ⚠️ | Prisma/TypeORM |
| **Vue.js** | `@vue/cli` / `create-vue` | `npm create vue@latest myproject` | `npm run dev/build` | `npm/yarn/pnpm` ⚠️ | N/A |
| **React** | `create-react-app` | `npx create-react-app myproject` | `npm run start/build/test` | `npm/yarn/pnpm` ⚠️ | N/A |
| **Express** | Manual / Generators | `express myproject` or manual | `npm run dev/start` | `npm/yarn/pnpm` ⚠️ | Sequelize/TypeORM |
| **Spring Boot** | `spring` CLI | `spring init myproject` | `./mvnw spring-boot:run` | `maven/gradle` | JPA/Hibernate |
| **ASP.NET Core** | `dotnet` CLI | `dotnet new webapp -n myproject` | `dotnet run/test/ef` | `dotnet/nuget` | Entity Framework |
| **Go** | `go` CLI | `go mod init myproject` | `go run/build/test` | `go mod` | GORM/native SQL |
| **Rust** | `cargo` | `cargo new myproject` | `cargo run/build/test` | `cargo` | Diesel/SQLx |

## 🚨 FRAMEWORK COMMAND PATTERNS

**IMPORTANT**: Les variables Makefile sont définies dans les fichiers `Makefile.*-part` correspondants.
Cette section documente les **patterns conceptuels** que l'IA doit suivre.

### Pattern Docker Container Execution:
**EXEC vs RUN Performance**: Les containers restent persistants et on utilise `${EXEC_CONTAINER} ${APP_CONTAINER}` pour optimiser les performances.

### Node.js Package Manager Detection Logic:
**Règle de détection automatique**:
- Si `yarn.lock` existe → utiliser `yarn install/build/dev`
- Si `pnpm-lock.yaml` existe → utiliser `pnpm install/build/dev`  
- Si `package-lock.json` ou aucun → utiliser `npm install/build/dev`
- Si demande explicite utilisateur → respecter le choix

**@AI-Kitchen: CHOOSE** - L'IA doit adapter les commandes selon la détection du gestionnaire de paquets.

## 🎯 KITCHEN PRIORITY BY FRAMEWORK

### 1. **Django Kitchen** (`.claude/templates/init-dev/stacks/python/django/`)
- ✅ CLI: `django-admin startproject` (génère structure + settings.py)
- ✅ Management: `python manage.py` commands + hello-doh target
- ✅ ORM: Django migrations system
- ✅ Testing: `python manage.py test` + `pytest-django`
- ✅ Templates: Makefile seulement (PAS de requirements.txt - généré par AI)

### 2. **Symfony Kitchen** (`.claude/templates/init-dev/stacks/php/symfony/`)
- ✅ CLI: `symfony new` avec Symfony CLI (génère composer.json)
- ✅ Console: `php bin/console` + Doctrine commands + hello-doh target
- ✅ Makers: `make:controller`, `make:entity`, `make:crud`
- ✅ ORM: Doctrine migrations + fixtures
- ✅ Templates: Makefile seulement (PAS de composer.json - généré par CLI)

### 3. **Laravel Kitchen** (`.claude/templates/init-dev/stacks/php/laravel/`)
- ✅ CLI: `composer create-project laravel/laravel` (génère composer.json)
- ✅ Artisan: `php artisan` commands + hello-doh target
- ✅ ORM: Eloquent migrations + seeders  
- ✅ Testing: `php artisan test` + PHPUnit
- ✅ Templates: Makefile seulement (PAS de composer.json - généré par CLI)

### 4. **Rails Kitchen** (`.claude/templates/init-dev/stacks/ruby/rails/`)  
- ✅ CLI: `rails new` avec configuration database (génère Gemfile)
- ✅ Console: `rails console`, `rails generate` + hello-doh target
- ✅ ORM: Active Record migrations
- ✅ Testing: `rails test` + RSpec
- ✅ Templates: Makefile seulement (PAS de Gemfile - généré par CLI)

### 5. **Node.js Kitchen** (`.claude/templates/init-dev/stacks/node/`)
- ✅ CLI: Framework-specific (`npx create-next-app`, `npm create vue`, etc.)
- ✅ Dev: `npm run dev` + hot reload + hello-doh target
- ✅ Build: `npm run build` + bundling
- ✅ Testing: Framework-specific (Jest, Vitest, etc.)
- ✅ Templates: Makefile seulement (PAS de package.json - généré par CLI)

## 🐳 ARCHITECTURE CONTAINER PERSISTANTS

**Pattern Optimisé**: Les containers restent actifs avec php-fpm ou sleep infinity pour éviter de multiplier les contextes Docker.

### Container Patterns par Framework

| Framework | Container Service | EXEC Target | Performance Benefit |
|-----------|-------------------|-------------|-------------------|
| **Django** | `python -c "import time; time.sleep(float('inf'))"` | WSGI/Django dev | Évite création contexte Python |
| **Symfony** | `php-fpm + sleep infinity` | php-fpm pool | Évite création contexte PHP |
| **Laravel** | `php-fpm + sleep infinity` | php-fpm pool | Évite création contexte PHP |
| **Rails** | `ruby -e "sleep"` | Rails server | Évite création contexte Ruby |
| **Node.js** | `node -e "setTimeout(() => {}, 24*60*60*1000)"` | Node.js daemon | Évite création contexte Node |

### Avantages Pattern EXEC vs RUN

```bash
# ❌ Pattern RUN (lent) - crée nouveau contexte à chaque fois
DJANGO_MANAGE = $(RUN_APP) python manage.py
# Chaque commande: docker run --rm -> nouveau container -> nouveau contexte

# ✅ Pattern EXEC (rapide) - utilise contexte persistant  
DJANGO_MANAGE = $(EXEC_APP) python manage.py
# Chaque commande: docker exec -> contexte existant -> instantané
```

### Services Supervisord Pattern

**Container App** maintient plusieurs processus via supervisord:
- **Web server**: php-fpm, gunicorn, puma, node
- **Task workers**: celery, queue workers
- **Frontend**: webpack-dev-server, vite dev
- **Keep-alive**: sleep infinity pour maintenir le container

## 🚨 RÈGLES CRITICAL PAR FRAMEWORK

1. **TOUJOURS utiliser le CLI officiel du framework**
   - Django → `django-admin startproject` (PAS de création manuelle)
   - Symfony → `symfony new` (PAS de composer seul)
   - Laravel → `composer create-project laravel/laravel` 
   - Rails → `rails new`

2. **TOUJOURS utiliser les commandes de management natives**
   - Django → `python manage.py migrate/shell/test`
   - Symfony → `php bin/console doctrine:migrate`  
   - Laravel → `php artisan migrate/tinker`
   - Rails → `rails db:migrate/console`

3. **TOUJOURS documenter la commande exacte avant exécution**
   - Chaque target Makefile doit afficher la commande avant exécution
   - Pattern: `@echo "📋 Command: <actual_command>"` puis `@<actual_command>`

4. **CHAQUE framework a sa propre kitchen**
   - Pas de mélange entre technologies
   - Variables spécifiques par framework  
   - Commands adaptées aux conventions du framework

5. **PAS de fichiers de dépendances dans les templates**
   - ❌ `composer.json` → généré par `symfony new` ou `composer create-project`
   - ❌ `requirements.txt` → généré par l'IA après analyse des besoins
   - ❌ `package.json` → généré par `create-next-app`, `npm create vue`, etc.
   - ❌ `Gemfile` → généré par `rails new`
   - ✅ Seuls les templates Docker + Makefile + configs système

6. **DÉTECTION AUTOMATIQUE des gestionnaires de paquets Node.js** ⚠️
   - Si `yarn.lock` existe → utiliser `yarn install/build/dev`
   - Si `pnpm-lock.yaml` existe → utiliser `pnpm install/build/dev`
   - Si `package-lock.json` ou aucun → utiliser `npm install/build/dev`
   - L'IA doit adapter les variables NPM_INSTALL/NPM_BUILD/NPM_DEV en conséquence

## 📋 PROCESSUS DE GÉNÉRATION DE DÉPENDANCES

1. **Framework CLI** → génère structure + fichier dépendances de base
2. **AI analyse** → détecte besoins spécifiques (testing, linting, workers, etc.)  
3. **AI détecte gestionnaire de paquets** → selon fichiers lock existants ou demande utilisateur
   - `yarn.lock` → utilise yarn pour toutes les commandes Node.js
   - `pnpm-lock.yaml` → utilise pnpm pour toutes les commandes Node.js  
   - `package-lock.json` ou aucun → utilise npm (défaut)
   - Demande explicite utilisateur → respecte le choix (npm/yarn/pnpm)
4. **AI complète** → ajoute dépendances manquantes dans fichier généré
5. **Post-build** → `make dev-setup` installe toutes les dépendances avec le bon gestionnaire

**Avantages :**
- Structure officielle du framework respectée
- Versions compatibles garanties par CLI framework
- AI adapte aux besoins spécifiques du projet
- Pas de conflit entre template et outils officiels

## 🎯 SPÉCIFICITÉS COMPLÈTES PAR FRAMEWORK

### Django Specifics

**Structure de projet Django :**
```
myproject/
├── manage.py                    # CLI Django
├── myproject/                   # Settings package
│   ├── settings.py             # Configuration principale
│   ├── urls.py                 # URL routing
│   └── wsgi.py                 # WSGI application
└── apps/                       # Applications Django
    └── hello/                  # App hello-doh
        ├── management/
        │   └── commands/
        │       └── hello.py    # Command hello-doh CLI
        ├── views.py            # Hello-doh web endpoint
        └── urls.py             # Routes hello-doh
```

**Variables d'environnement Django :**
```bash
DJANGO_SETTINGS_MODULE=myproject.settings
DJANGO_SECRET_KEY=...
DJANGO_DEBUG=True
DATABASE_URL=postgres://user:pass@db:5432/myproject
DOH_HELLOWORLD=abc123...        # Pour validation hello-doh
```

**Dotenv cascade Django :**
- `.env` → settings.py → environment variables
- Test: `DJANGO_SETTINGS_MODULE=myproject.settings_test` → `.env.test`

**Hello-doh Django implémentation :**
**Prérequis:** `make dev` (Docker up) + `make dev-setup` (dependencies) + Django welcome page working
1. `make hello-doh` → `python manage.py startapp hello`
2. AI génère `hello/views.py` avec endpoint `/hello` + DOH_HELLOWORLD
3. AI génère `hello/management/commands/hello.py` avec DOH_HELLOWORLD
4. AI configure urls.py routing

---

### Symfony Specifics

**Structure de projet Symfony :**
```
myproject/
├── bin/console                  # CLI Symfony
├── config/                     # Configuration
│   ├── packages/
│   └── routes.yaml
├── src/                        # Source code
│   ├── Controller/
│   │   └── HelloController.php # Hello-doh web endpoint
│   └── Command/
│       └── HelloCommand.php    # Hello-doh CLI command
└── var/                        # Cache, logs, sessions
```

**Variables d'environnement Symfony :**
```bash
APP_ENV=dev                     # Environment selector
APP_SECRET=...
DATABASE_URL=mysql://user:pass@db:3306/myproject
DOH_HELLOWORLD=abc123...        # Pour validation hello-doh
```

**Dotenv cascade Symfony :**
- `.env` → `.env.local` → `.env.dev` → `.env.dev.local`
- Test: `APP_ENV=test` → `.env.test`

**Hello-doh Symfony implémentation :**
**Prérequis:** `make dev` (Docker up) + `make dev-setup` (dependencies) + Symfony demo page working
1. `make hello-doh` → `make:controller HelloController --no-template` + `make:command HelloCommand`
2. AI génère HelloController avec route `/hello` + DOH_HELLOWORLD
3. AI génère HelloCommand avec DOH_HELLOWORLD validation

---

### Laravel Specifics

**Structure de projet Laravel :**
```
myproject/
├── artisan                     # CLI Laravel
├── config/                     # Configuration
├── app/
│   ├── Http/Controllers/
│   │   └── HelloController.php # Hello-doh web endpoint
│   └── Console/Commands/
│       └── HelloCommand.php    # Hello-doh CLI command
└── routes/
    └── web.php                 # Routes configuration
```

**Variables d'environnement Laravel :**
```bash
APP_ENV=local                   # Environment selector
APP_KEY=...
DB_CONNECTION=mysql
DB_HOST=mariadb
DB_DATABASE=myproject
DOH_HELLOWORLD=abc123...        # Pour validation hello-doh
```

**Dotenv cascade Laravel :**
- `.env` → `.env.local` (simple cascade)
- Test: `APP_ENV=testing` → `.env.testing`

**Hello-doh Laravel implémentation :**
**Prérequis:** `make dev` (Docker up) + `make dev-setup` (dependencies) + Laravel welcome page working
1. `make hello-doh` → `make:controller HelloController` + `make:command HelloCommand`
2. AI génère HelloController avec méthode + route web.php
3. AI génère HelloCommand avec handle() + DOH_HELLOWORLD

---

### Rails Specifics

**Structure de projet Rails :**
```
myproject/
├── bin/rails                   # CLI Rails
├── config/
│   ├── routes.rb              # Routes configuration
│   └── environments/
├── app/controllers/
│   └── hello_controller.rb     # Hello-doh web endpoint
└── lib/tasks/
    └── hello.rake              # Hello-doh CLI task
```

**Variables d'environnement Rails :**
```bash
RAILS_ENV=development           # Environment selector
SECRET_KEY_BASE=...
DATABASE_URL=postgresql://user:pass@db:5432/myproject
DOH_HELLOWORLD=abc123...        # Pour validation hello-doh
```

**Hello-doh Rails implémentation :**
**Prérequis:** `make dev` (Docker up) + `make dev-setup` (dependencies) + Rails welcome page working
1. `make hello-doh` → `generate controller Hello index` + `generate task hello greet`
2. AI génère HelloController avec action index + DOH_HELLOWORLD
3. AI génère lib/tasks/hello.rake avec task greet + DOH_HELLOWORLD

---

### Node.js Specifics

**Structure de projet Node.js/Express :**
```
myproject/
├── package.json               # Dependencies + scripts
├── src/
│   ├── routes/
│   │   └── hello.js          # Hello-doh web endpoint
│   └── commands/
│       └── hello.js          # Hello-doh CLI command
└── bin/
    └── cli.js                # CLI entry point
```

**Variables d'environnement Node.js :**
```bash
NODE_ENV=development           # Environment selector
PORT=3000
DATABASE_URL=postgresql://user:pass@db:5432/myproject
DOH_HELLOWORLD=abc123...       # Pour validation hello-doh
```

**Hello-doh Node.js implémentation :**
**Prérequis:** `make dev` (Docker up) + `make dev-setup` (dependencies) + Express/framework welcome working
1. `make hello-doh` → AI crée structure routes + CLI commands
2. AI génère `/hello` route avec Express + DOH_HELLOWORLD
3. AI génère CLI command dans package.json scripts + DOH_HELLOWORLD

---

## 🚨 RÈGLES CRITIQUES D'IMPLÉMENTATION

### Framework CLI Tools Priority
1. **TOUJOURS** utiliser les outils officiels du framework
2. **JAMAIS** créer des fichiers manuellement si un CLI existe
3. **TOUJOURS** respecter les conventions de structure

### Hello World Implementation Sequence (CRITICAL ORDER)
1. **Docker up** → `make dev` pour démarrer tous les services
2. **Dependencies** → `make dev-setup` pour installer toutes les dépendances post-build
3. **Framework hello** → Tester hello world officiel du framework (Django welcome page, Symfony demo, etc.)
4. **hello-doh custom** → `make hello-doh` pour créer + AI génère le hello world DOH personnalisé

### Hello-doh Implementation Pattern
1. **Prérequis**: Docker running + dependencies installed + framework hello world working
2. **CLI du framework** crée la structure de base (make:controller, startapp, generate)
3. **AI génère le code** dans les fichiers créés par le CLI avec DOH_HELLOWORLD
4. **Test web + CLI** validation DOH_HELLOWORLD dans les deux interfaces
5. **Success feedback** avec valeur DOH_HELLOWORLD visible

### Environment Variables Management
- Chaque framework a sa propre logique de cascade dotenv
- Test environments isolés avec configurations spécifiques
- DOH_HELLOWORLD toujours validé dans web + CLI

Cette référence assure que `/doh:init-dev` implémente correctement les spécificités de chaque framework !