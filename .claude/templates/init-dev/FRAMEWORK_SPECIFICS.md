# Framework Specifics - Complete Reference for DOH init-dev
# =================================================================
# 
# Ce fichier contient TOUTES les spécificités par framework pour /doh:init-dev
# L'IA DOIT consulter ce fichier avant de générer des stacks pour comprendre
# les conventions, outils, et patterns spécifiques à chaque technologie

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