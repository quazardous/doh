# Environment Configuration Layers - DOH Kitchen

This document explains the multi-layered environment configuration system used by the DOH Kitchen to manage environment variables across Docker containers, frameworks, and frontend builds.

## Environment Layer Architecture

The DOH Kitchen implements a sophisticated multi-layer environment system that ensures consistent configuration across all components while allowing appropriate separation of concerns.

### Layer Overview
```
┌─────────────────────────────────────────────────────────────┐
│                     Environment Layers                      │
├─────────────────────────────────────────────────────────────┤
│ Layer 0: Host System Environment (UID, GID, system vars)   │
│ Layer 1: Docker Orchestration (docker-compose.env)         │
│ Layer 2: Container Runtime (Docker ENV, volume mounts)     │
│ Layer 3: Framework Configuration (.env, dotenv files)      │
│ Layer 4: Frontend Build (Vite, Webpack, build-time)       │
│ Layer 5: Development Tools (testing, linting, debugging)   │
└─────────────────────────────────────────────────────────────┘
```

## Layer 0: Host System Environment

### Host Environment Variables
**Purpose:** System-level variables required for proper Docker operation and permission handling
**Scope:** Host machine environment, inherited by Docker Compose and containers
**Critical Variables:** UID, GID for file permission synchronization

```bash
# User/Group identification for Docker volume permissions
export UID=$(id -u)     # Current user ID
export GID=$(id -g)     # Current group ID

# System environment (typically set by OS)
HOME=/home/username     # User home directory
USER=username          # Current username
PATH=/usr/local/bin:/usr/bin:/bin

# Docker-related system variables
DOCKER_HOST=unix:///var/run/docker.sock  # Docker daemon socket
COMPOSE_PROJECT_NAME=my-app               # Override project name
```

### UID/GID Permission Handling
**Critical for DOH Kitchen:** Ensures files created in containers have correct ownership on host

#### Method 1: Command Line Export (Manual)
```bash
# Before any Docker commands - export in shell session
export UID && export GID=$(id -g)
docker compose --env-file docker-compose.env up -d
docker compose --env-file docker-compose.env exec app bash
```

#### Method 2: Inline Command Line (Per-command)
```bash
# Export inline for single commands + load docker-compose.env
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env up -d
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app bash
```

#### Method 3: Makefile Management (Recommended)
```makefile
# Makefile handles UID/GID automatically + docker-compose.env file loading
DOCKER_COMPOSE := export UID && export GID=$$(id -g) && docker compose --env-file docker-compose.env
RUN_APP := $(DOCKER_COMPOSE) exec app

# All targets automatically export UID/GID + load docker-compose.env
dev:
	$(DOCKER_COMPOSE) up -d

sh:
	$(RUN_APP) bash

build:
	$(DOCKER_COMPOSE) build

# CRITICAL: --env-file docker-compose.env ensures Docker Compose reads the orchestration file
```

#### Docker Compose Integration
```yaml
# docker-compose.yml - receives UID/GID from any method above
services:
  app:
    build:
      args:
        UID: ${UID:-1000}      # Uses exported UID or defaults to 1000
        GID: ${GID:-1000}      # Uses exported GID or defaults to 1000
    user: "${UID}:${GID}"
```

#### UID/GID Management Comparison
| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| **Command Line Export** | One-off development sessions | Simple, explicit control | Must remember to export |
| **Inline Export** | Script automation, CI/CD | No session state needed | Verbose, repetitive |
| **Makefile Management** | Daily development workflow | Automatic, consistent | Requires make tool |

**DOH Kitchen Recommendation:** Use Method 3 (Makefile) for development, Method 2 (Inline) for automation.

### Host System Detection
**Platform-specific environment variables:**

```bash
# Linux/macOS
OSTYPE=linux-gnu        # Operating system type
HOSTTYPE=x86_64         # Hardware architecture

# Windows (WSL2)
WSLENV=PATH/l:LD_LIBRARY_PATH/l    # WSL environment pass-through
WSL_DISTRO_NAME=Ubuntu             # WSL distribution name

# macOS (Docker Desktop)
DOCKER_DEFAULT_PLATFORM=linux/amd64  # Platform architecture
```

### Host Prerequisites Validation
```bash
# Check required host environment
echo "UID: ${UID:-not-set}"
echo "GID: ${GID:-not-set}"
which docker || echo "Docker not installed"
which docker-compose || echo "Docker Compose not installed"
which mkcert || echo "mkcert not installed"
```

## Layer 1: Docker Orchestration Environment

### Primary Files
- **`docker-compose.env`** - Main orchestration configuration (at project root)

### docker-compose.env (Orchestration Layer)
**Purpose:** Controls Docker Compose service configuration and container orchestration
**Location:** Project root (ALWAYS)
**Usage:** Generated as `docker-compose.env-docker`, then copied to `docker-compose.env` by `make env-config`

```bash
# Project identification
PROJECT_NAME=my-app

# Port configuration
EXTERNAL_HTTP_PORT=8080
EXTERNAL_HTTPS_PORT=8443
EXTERNAL_TRAEFIK_PORT=8081

# Container configuration
CONTAINER_REGISTRY=docker.io
APP_IMAGE_TAG=latest

# Network configuration
NETWORK_NAME=${PROJECT_NAME}-network
```


## Layer 2: Container Runtime Environment

### Docker Environment Variables
**Purpose:** Container-level configuration and service discovery
**Mechanism:** Docker Compose reads from OS environment + docker-compose.env file (via --env-file)

**Environment Variable Resolution for Docker Compose:**
```bash
# Docker Compose ONLY sees:
# 1. OS environment variables (exported in shell)
# 2. docker-compose.env file (when using --env-file docker-compose.env)

# Example: PROJECT_NAME comes from docker-compose.env or OS export
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env up -d
```

**Docker Compose Configuration:**
```yaml
# docker-compose.yml
# Variables like ${PROJECT_NAME} are resolved by Docker Compose from:
# - OS environment (export PROJECT_NAME=my-app)  
# - docker-compose.env file (PROJECT_NAME=my-app)

services:
  app:
    environment:
      # These are set INSIDE the container
      - CONTAINER_ROLE=app                # Static value
      - PHP_INI_SCAN_DIR=:/etc/php/conf.d:/app/docker/app/php
    env_file:
      # This file is read by Docker Compose and injected INTO the container
      - .env
```

### Volume-Mounted Environment Files
**Purpose:** Make host environment files available inside containers
**Benefits:** Allows container access to host-managed configuration

```yaml
services:
  app:
    volumes:
      - ./.env:/app/.env:ro
      - ./.env.test:/app/.env.test:ro
      - ./docker/app/php.ini:/usr/local/etc/php/conf.d/app.ini:ro
```

## Layer 3: Framework Configuration

### Application Environment Files
- **`.env`** - Main application environment variables (at project root)
- **`.env.test`** - Testing environment overrides
- **`.env.local`** - Local development overrides (not committed)

### .env (Application Environment)
**Purpose:** Application-level environment variables loaded by frameworks
**Location:** Project root
**Usage:** Volume mounted into containers and loaded by framework dotenv libraries

```bash
# Application configuration
APP_ENV=local
APP_DEBUG=true
APP_URL=https://app.${PROJECT_NAME}.localhost

# Database connection
DB_CONNECTION=postgresql
DB_HOST=database
DB_PORT=5432
DB_DATABASE=${PROJECT_NAME}
DB_USERNAME=${PROJECT_NAME}
DB_PASSWORD=${PROJECT_NAME}

# Cache and sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=redis
REDIS_PORT=6379

# DOH validation
DOH_HELLOWORLD=${DOH_HELLOWORLD}
```

### .env.test (Testing Environment)
**Purpose:** Override environment variables for testing scenarios
**Usage:** Loaded by frameworks when `APP_ENV=testing` or via explicit test commands

```bash
# Testing database
DB_DATABASE=${PROJECT_NAME}_test
DB_HOST=database-test

# Testing cache (in-memory)
CACHE_DRIVER=array
SESSION_DRIVER=array

# Testing queue (synchronous)
QUEUE_CONNECTION=sync

# Disable external services in tests
MAIL_DRIVER=log
BROADCAST_DRIVER=log
```

### Framework-Specific Environment Handling
Different frameworks have different environment variable loading patterns:

#### Django Environment Pattern
**File:** `settings.py` or `settings/local.py`
**Loading:** Manual loading via python-dotenv or django-environ

```python
# settings/base.py
import os
from pathlib import Path
import environ

# Build paths inside the project
BASE_DIR = Path(__file__).resolve().parent.parent

# Environment variables
env = environ.Env(
    DEBUG=(bool, False),
    DOH_HELLOWORLD=(str, ''),
)

# Read .env file
environ.Env.read_env(BASE_DIR / '.env')

# Application configuration
DEBUG = env('DEBUG')
SECRET_KEY = env('SECRET_KEY')
DOH_HELLOWORLD = env('DOH_HELLOWORLD')

# Database configuration from environment
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': env('DB_DATABASE'),
        'USER': env('DB_USERNAME'),
        'PASSWORD': env('DB_PASSWORD'),
        'HOST': env('DB_HOST'),
        'PORT': env('DB_PORT'),
    }
}
```

#### Laravel Environment Pattern
**File:** `.env` (framework standard)
**Loading:** Automatic loading via Dotenv (built-in)

```php
<?php
// config/app.php
return [
    'name' => env('APP_NAME', 'Laravel'),
    'env' => env('APP_ENV', 'production'),
    'debug' => env('APP_DEBUG', false),
    'url' => env('APP_URL', 'http://localhost'),
    
    // DOH validation
    'doh_helloworld' => env('DOH_HELLOWORLD', ''),
];

// config/database.php
return [
    'default' => env('DB_CONNECTION', 'mysql'),
    'connections' => [
        'pgsql' => [
            'driver' => 'pgsql',
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '5432'),
            'database' => env('DB_DATABASE', 'forge'),
            'username' => env('DB_USERNAME', 'forge'),
            'password' => env('DB_PASSWORD', ''),
        ],
    ],
];
```

#### Express/Node.js Environment Pattern
**File:** `.env` (via dotenv package)
**Loading:** Manual loading via require('dotenv').config()

```javascript
// server.js or app.js
require('dotenv').config();
// require('dotenv-flow').config(); can cascade load like Symfony (.env -> .env.local -> etc)

const express = require('express');
const app = express();

// Environment configuration
const config = {
    env: process.env.NODE_ENV || 'development',
    port: process.env.PORT || 3000,
    database: {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 5432,
        name: process.env.DB_DATABASE,
        user: process.env.DB_USERNAME,
        password: process.env.DB_PASSWORD,
    },
    doh: {
        helloworld: process.env.DOH_HELLOWORLD || '',
    }
};

// Application setup using environment variables
app.listen(config.port, () => {
    console.log(`Server running on port ${config.port}`);
    console.log(`Environment: ${config.env}`);
    console.log(`DOH HelloWorld: ${config.doh.helloworld}`);
});
```

### Framework Environment Cascade Priority
**Priority Order:** More specific environments override general ones

1. **Framework-specific files** (highest priority)
2. **Container environment variables**
3. **Volume-mounted .env files**
4. **Docker Compose environment**
5. **System environment variables** (lowest priority)

## Layer 4: Frontend Build Environment

### Frontend Environment Variable Exposure
Frontend applications require special handling for environment variables since they run in browsers:

#### Vite Environment Pattern (Vue.js, React)
**Files:** `.env`, `.env.local`, `.env.production`
**Prefix:** `VITE_` for public variables

```bash
# .env (backend variables - NOT exposed to frontend)
DB_PASSWORD=secret-password
API_SECRET_KEY=backend-only-secret

# Frontend-accessible variables (VITE_ prefix)
VITE_APP_NAME=My Application
VITE_API_BASE_URL=https://api.${PROJECT_NAME}.localhost
VITE_DOH_HELLOWORLD=${DOH_HELLOWORLD}
VITE_APP_VERSION=1.0.0
```

**Vite Configuration:**
```javascript
// vite.config.js
import { defineConfig, loadEnv } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig(({ command, mode }) => {
  // Load environment variables
  const env = loadEnv(mode, process.cwd(), '');
  
  return {
    plugins: [vue()],
    define: {
      // Expose additional variables manually if needed
      __DOH_HELLOWORLD__: JSON.stringify(env.DOH_HELLOWORLD),
    },
    server: {
      port: 3000,
      host: '0.0.0.0',
    },
  };
});
```

#### Webpack Environment Pattern (React, Angular)
**Files:** `.env`, `.env.local`, `.env.production`
**Prefix:** `REACT_APP_` for React, custom prefix for others

```bash
# React environment variables (REACT_APP_ prefix)
REACT_APP_API_URL=https://api.${PROJECT_NAME}.localhost
REACT_APP_DOH_HELLOWORLD=${DOH_HELLOWORLD}
REACT_APP_ENVIRONMENT=${APP_ENV}

# Angular environment variables (NG_APP_ custom prefix)
NG_APP_API_URL=https://api.${PROJECT_NAME}.localhost
NG_APP_DOH_HELLOWORLD=${DOH_HELLOWORLD}
```

**Webpack Configuration:**
```javascript
// webpack.config.js
const webpack = require('webpack');
const dotenv = require('dotenv');

// Load environment variables
const env = dotenv.config().parsed || {};

module.exports = {
  plugins: [
    new webpack.DefinePlugin({
      'process.env': JSON.stringify({
        ...Object.keys(env)
          .filter(key => key.startsWith('REACT_APP_'))
          .reduce((acc, key) => {
            acc[key] = env[key];
            return acc;
          }, {}),
      }),
    }),
  ],
};
```

### Frontend-Backend Environment Synchronization
**Challenge:** Frontend needs access to backend configuration
**Solution:** Environment variable sharing with proper security

```bash
# Shared configuration (safe for frontend)
VITE_APP_NAME=${PROJECT_NAME}
VITE_API_BASE_URL=https://app.${PROJECT_NAME}.localhost/api
VITE_DOH_HELLOWORLD=${DOH_HELLOWORLD}

# Backend-only (never exposed to frontend)
DB_PASSWORD=secret
API_SECRET_KEY=backend-secret
JWT_SECRET=jwt-secret
```

## Layer 5: Development Tools Environment

### Testing Environment Configuration
**Purpose:** Isolated environment for automated testing
**Mechanism:** Separate environment files and container configurations

```bash
# .env.test - Testing overrides
APP_ENV=testing
DB_DATABASE=${PROJECT_NAME}_test
CACHE_DRIVER=array
SESSION_DRIVER=array
QUEUE_CONNECTION=sync
MAIL_DRIVER=log

# Test-specific variables
TEST_OUTPUT_VERBOSE=true
COVERAGE_ENABLED=true
PARALLEL_TESTING=true
```

### Linting Environment Configuration
**Purpose:** Code quality tool configuration
**Files:** `.env.lint`, linter-specific config files

```bash
# .env.lint
ESLINT_CONFIG=.eslintrc.js
PRETTIER_CONFIG=.prettierrc
PHP_CS_FIXER_CONFIG=.php-cs-fixer.php
PYTHON_LINTER=ruff
```

### Debug Environment Configuration
**Purpose:** Development debugging and logging
**Variables:** Debug flags, logging levels, profiling

```bash
# Debug configuration
DEBUG=true
LOG_LEVEL=debug
QUERY_DEBUG=true
PROFILER_ENABLED=true
XDEBUG_MODE=debug
XDEBUG_CLIENT_HOST=host.docker.internal
```

## Environment Loading Order & Priority

### Container Startup Environment Loading
1. **Host system environment** (Layer 0: UID, GID, system variables)
2. **Docker Compose environment** (Layer 1: docker-compose.env)
3. **Container runtime environment** (Layer 2: Docker ENV sections)
4. **Volume-mounted files** (Layer 3: .env, .env.local, .env.test)
5. **Framework-specific loading** (Layer 3: application startup)
6. **Frontend build-time** (Layer 4: Vite, Webpack processing)
7. **Development tools** (Layer 5: testing, linting overrides)

### Framework Environment Resolution
**Django:**
```python
# Priority order (highest to lowest):
# 1. environment variables
# 2. .env.local
# 3. .env.{APP_ENV}
# 4. .env
```

**Laravel:**
```php
// Priority order (highest to lowest):
// 1. System environment variables
// 2. .env.local
// 3. .env.{APP_ENV}
// 4. .env
```

**Node.js:**
```javascript
// Priority order (highest to lowest):
// 1. process.env (system environment)
// 2. .env.local
// 3. .env.{NODE_ENV}
// 4. .env
```

## Security Considerations

### Sensitive Data Handling
**Never expose in frontend:**
- Database passwords
- API secrets
- JWT signing keys
- Third-party API keys
- Internal service tokens

**Safe for frontend exposure:**
- API endpoints (public)
- Application names
- DOH validation hashes
- Feature flags
- Public configuration

### Environment File Security
```bash
# .gitignore - Never commit sensitive environment files
.env
.env.local
.env.*.local
.env.production

# Commit only templates and examples
.env.example
.env.docker
.env.test.docker
```

## Troubleshooting Environment Issues

### Common Environment Problems

#### Variables Not Loading
**Symptoms:** Application can't find configuration values
**Debug Steps:**
1. Check file naming (`.env` vs `.env.example`)
2. Verify file permissions and ownership
3. Confirm volume mounting in docker-compose.yml
4. Check framework-specific loading code

#### Variable Override Issues
**Symptoms:** Wrong values being used
**Debug Steps:**
1. Check environment loading priority
2. Verify container environment variables
3. Check for multiple .env files
4. Use framework debug commands

#### Frontend Variables Not Available
**Symptoms:** `undefined` variables in browser console
**Debug Steps:**
1. Check variable prefix (VITE_, REACT_APP_)
2. Verify build tool configuration
3. Check browser developer tools
4. Confirm variable is in build output

### Debug Commands
```bash
# Check UID/GID configuration (Layer 0)
echo "Host UID: $(id -u), GID: $(id -g)"
echo "Exported UID: ${UID:-not-set}, GID: ${GID:-not-set}"

# Method-specific UID/GID debugging
# Method 1: Check if variables are exported in session
env | grep -E "^(UID|GID)="

# Method 2: Test inline export
export UID && export GID=$(id -g) && echo "UID: $UID, GID: $GID"

# Method 3: Test Makefile variable expansion
make -n dev | grep "export UID"  # Shows what make would execute

# Check environment loading in containers
make sh  # Enter container
env | grep DOH_  # Check DOH variables
env | grep DB_   # Check database variables
env | sort       # See all environment variables

# Framework-specific environment debugging
# Django
$(RUN_APP) python manage.py shell -c "from django.conf import settings; print(settings.DOH_HELLOWORLD)"

# Laravel  
$(RUN_APP) php artisan env
$(RUN_APP) php artisan tinker --execute="echo env('DOH_HELLOWORLD');"

# Node.js
$(RUN_APP) node -e "console.log('DOH_HELLOWORLD:', process.env.DOH_HELLOWORLD)"
```

## Best Practices

### Environment Organization
1. **Keep sensitive data in .env** (not committed to git)
2. **Use .env.example** as documentation template
3. **Separate concerns** by environment layer
4. **Use consistent naming** across projects
5. **Document all variables** with comments

### Framework Integration
1. **Follow framework conventions** for environment loading
2. **Use framework-provided libraries** (django-environ, dotenv)
3. **Validate required variables** at application startup
4. **Provide sensible defaults** where appropriate

### Security Guidelines
1. **Never commit .env files** to version control
2. **Use prefixes** for frontend variable exposure
3. **Separate development/production** configurations
4. **Regularly rotate secrets** in production environments
5. **Use secret management** for production deployments

---

**The environment layer system ensures consistent, secure, and maintainable configuration management across all components of the DOH development stack.**