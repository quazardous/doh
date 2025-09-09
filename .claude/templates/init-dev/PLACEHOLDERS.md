# Kitchen Template Placeholder System

This document explains the global placeholder replacement system used across all DOH Kitchen templates.

## Placeholder Format

All placeholders use double curly brace syntax: `{{PLACEHOLDER_NAME}}`

### Core Project Placeholders

| Placeholder | Description | Example | Source |
|-------------|-------------|---------|---------|
| `{{PROJECT_NAME}}` | Project directory name | `my-app` | Directory basename |
| `{{PROJECT_NAME_UPPER}}` | Project name in uppercase | `MY_APP` | Derived from PROJECT_NAME |
| `{{PROJECT_NAME_LOWER}}` | Project name in lowercase | `my-app` | Derived from PROJECT_NAME |
| `{{PROJECT_NAME_CAMEL}}` | Project name in camelCase | `myApp` | Derived from PROJECT_NAME |
| `{{PROJECT_NAME_PASCAL}}` | Project name in PascalCase | `MyApp` | Derived from PROJECT_NAME |
| `{{PROJECT_NAME_SNAKE}}` | Project name in snake_case | `my_app` | Derived from PROJECT_NAME |

### Framework Detection Placeholders

| Placeholder | Description | Example | Detection Method |
|-------------|-------------|---------|------------------|
| `{{FRAMEWORK}}` | Detected framework name | `django` | File analysis |
| `{{FRAMEWORK_VERSION}}` | Framework version | `5.0.0` | Package files |
| `{{FRAMEWORK_UPPER}}` | Framework in uppercase | `DJANGO` | Derived |
| `{{PYTHON_VERSION}}` | Python version for Python frameworks | `3.12` | Framework requirements |
| `{{NODE_VERSION}}` | Node.js version for JS frameworks | `20.11.0` | Package.json engines |
| `{{PHP_VERSION}}` | PHP version for PHP frameworks | `8.3` | Composer.json |

### Database Placeholders

| Placeholder | Description | Example | Default |
|-------------|-------------|---------|---------|
| `{{DB_TYPE}}` | Database type | `mariadb` | From user request |
| `{{DB_VERSION}}` | Database version | `11.7` | Latest stable |
| `{{DATABASE}}` | Database type for framework commands | `mysql` | From framework detection |
| `{{DATABASE_URL}}` | Complete database connection URL | `mysql://user:pass@host/db` | Constructed from components |
| `{{DB_NAME}}` | Database name | `my-app` | Same as PROJECT_NAME |
| `{{DB_USER}}` | Database user | `my-app` | Same as PROJECT_NAME |
| `{{DB_PASSWORD}}` | Database password | `my-app` | Same as PROJECT_NAME |
| `{{DB_ROOT_PASSWORD}}` | Database root password | `my-app` | Same as PROJECT_NAME |

### Frontend Technology Placeholders

| Placeholder | Description | Example | Detection |
|-------------|-------------|---------|-----------|
| `{{FRONTEND_TYPE}}` | Frontend framework | `vue3` | Package.json analysis |
| `{{FRONTEND_VERSION}}` | Frontend version | `3.4.0` | Package.json |
| `{{BUILD_TOOL}}` | Build tool type | `vite` | Config file detection |
| `{{BUILD_TOOL_VERSION}}` | Build tool version | `5.0.0` | Package.json |

### Container Configuration Placeholders

| Placeholder | Description | Example | Usage |
|-------------|-------------|---------|--------|
| `{{CONTAINER_DIR}}` | Container directory | `./docker` | User specified |
| `{{BASE_IMAGE}}` | Base Docker image | `python:3.12-slim` | Framework dependent |
| `{{EXPOSE_PORT}}` | Application port | `8000` | Framework default |
| `{{EXPOSE_PORTS}}` | Multiple ports for multi-stage builds | `8000 3000` | Multi-stage Dockerfile |
| `{{EXTERNAL_HTTP_PORT}}` | External HTTP port | `8080` | Docker orchestration |
| `{{EXTERNAL_HTTPS_PORT}}` | External HTTPS port | `8443` | Docker orchestration |
| `{{EXTERNAL_TRAEFIK_PORT}}` | External Traefik dashboard port | `8081` | Docker orchestration |

### DOH System Placeholders

| Placeholder | Description | Example | Generation |
|-------------|-------------|---------|------------|
| `{{DOH_HELLOWORLD}}` | Unique validation hash | `f4a7b2c8e9d1a6f3` | SHA256 generation |
| `{{DOH_HELLOWORLD_TEST}}` | Test environment validation hash | `f4a7b2c8e9d1a6f4` | SHA256 generation for tests |
| `{{DOH_VERSION}}` | DOH system version | `1.0.0` | System version |
| `{{TIMESTAMP}}` | Generation timestamp | `2025-01-15T10:30:00Z` | Current time |

### Framework Command Placeholders

| Placeholder | Description | Example | Usage |
|-------------|-------------|---------|--------|
| `{{FRAMEWORK_CMD}}` | Framework-specific run command | `python manage.py runserver` | Container startup |
| `{{FRAMEWORK_MIGRATE_COMMAND}}` | Framework migration command | `python manage.py migrate` | Makefile targets |

## Placeholder Processing Rules

### 1. Case Transformation Rules

**PROJECT_NAME transformations:**
```bash
# Input: "my-awesome-app"
PROJECT_NAME="my-awesome-app"           # Original
PROJECT_NAME_UPPER="MY-AWESOME-APP"     # Uppercase
PROJECT_NAME_LOWER="my-awesome-app"     # Lowercase  
PROJECT_NAME_CAMEL="myAwesomeApp"       # camelCase
PROJECT_NAME_PASCAL="MyAwesomeApp"      # PascalCase
PROJECT_NAME_SNAKE="my_awesome_app"     # snake_case
```

### 2. Framework-Specific Rules

**Python Frameworks (Django, Flask, FastAPI):**
- `{{BASE_IMAGE}}` → `python:{{PYTHON_VERSION}}-slim`
- `{{EXPOSE_PORT}}` → `8000`
- `{{FRAMEWORK_CMD}}` → Framework-specific run command

**PHP Frameworks (Laravel, Symfony):**
- `{{BASE_IMAGE}}` → `php:{{PHP_VERSION}}-fpm`
- `{{EXPOSE_PORT}}` → `8000`
- `{{FRAMEWORK_CMD}}` → Framework-specific serve command

**Node.js Frameworks (Express, Next.js):**
- `{{BASE_IMAGE}}` → `node:{{NODE_VERSION}}-bookworm`
- `{{EXPOSE_PORT}}` → `3000`
- `{{FRAMEWORK_CMD}}` → Framework-specific start command


## File Template Patterns

### 1. Configuration File Templates

**docker-compose.yml template:**
```yaml
services:
  app:
    build:
      context: .
      dockerfile: {{CONTAINER_DIR}}/app/Dockerfile
    labels:
      - "dev.project={{PROJECT_NAME}}"
    environment:
      - APP_ENV=test # force test env for framework
```

**Dockerfile template:**
```dockerfile
FROM {{BASE_IMAGE}} AS {{FRAMEWORK}}-base
WORKDIR /app

# Framework-specific setup based on detected framework
RUN apt-get update && apt-get install -y build-essential

EXPOSE {{EXPOSE_PORT}}
```

### 2. Environment File Templates

**.env template:**
```bash
# Project Configuration
PROJECT_NAME={{PROJECT_NAME}}
DOH_HELLOWORLD={{DOH_HELLOWORLD}}

# Database Configuration  
DB_DATABASE={{DB_NAME}}
DB_USER={{DB_USER}}
DB_PASSWORD={{DB_PASSWORD}}
```

### 3. Makefile Templates

**Makefile template:**
```makefile
PROJECT_NAME := {{PROJECT_NAME}}
DOCKER_COMPOSE := export UID && export GID=$$(id -g) && docker compose --env-file docker-compose.env
RUN_APP := $(DOCKER_COMPOSE) exec app

# Framework-specific targets added based on detected framework
migrate:
	$(RUN_APP) {{FRAMEWORK_MIGRATE_COMMAND}}
```

## Template Processing Order

### 1. Analysis Phase
1. **Project Detection**: Extract PROJECT_NAME from directory
2. **Framework Detection**: Analyze files for framework patterns
3. **Technology Detection**: Detect database, frontend, build tools
4. **Version Detection**: Extract version requirements

### 2. Placeholder Generation Phase
1. **Core Placeholders**: Generate project name variations
2. **Framework Placeholders**: Set framework-specific values
3. **Technology Placeholders**: Set database/frontend values
4. **Environment Placeholders**: Generate hashes and timestamps

### 3. Template Processing Phase
1. **File Discovery**: Find all template files in kitchen
2. **Placeholder Replacement**: Replace all {{PLACEHOLDER}} patterns
3. **File Generation**: Write processed files to target locations

## Advanced Placeholder Features

### 1. Nested Placeholders
```yaml
ssl_domain: "{{SSL_PROTOCOL}}://app.{{PROJECT_NAME}}.localhost"
# Where SSL_PROTOCOL resolves to "https"
# Result: "https://app.my-app.localhost"
```

### 2. Framework-Specific Template Selection
Kitchen selects different template sections based on detected technology:
```dockerfile
# Selected when framework detection finds Node.js
FROM node:{{NODE_VERSION}} AS frontend-build
WORKDIR /app/frontend
COPY package*.json ./
RUN npm ci
```

### 3. Default Value Support
Default values are handled by the placeholder replacement system during Kitchen processing based on detected technologies.

## Error Handling

### 1. Missing Placeholder Detection
- Kitchen validates all placeholders are resolved
- Fails with clear error if {{PLACEHOLDER}} remains unresolved
- Lists all unresolved placeholders in error message

### 2. Invalid Value Detection  
- Validates placeholder values against expected patterns
- PROJECT_NAME must be valid directory name
- Version numbers must follow semantic versioning
- Framework names must match supported frameworks

### 3. Circular Reference Prevention
- Detects circular placeholder references
- Prevents infinite replacement loops
- Fails gracefully with dependency chain error

## Kitchen Template Integration

### 1. Template File Naming
```
.claude/templates/init-dev/core/
├── docker-compose.yml             # Main orchestration template
├── Dockerfile                     # Multi-stage build template
├── Makefile.seed                  # Development commands base template
└── .env-docker                    # Environment config template for dist file
```

### 2. Stack-Specific Templates
```
.claude/templates/init-dev/stacks/
├── python/
```

### 3. Conditional Template Selection
Kitchen selects appropriate templates based on detected technologies:
- Framework detection drives base template selection
- Frontend detection adds frontend-specific templates
- Database detection includes database configuration templates

---

**The placeholder system ensures consistent, automated template processing across all Kitchen-generated development stacks.**