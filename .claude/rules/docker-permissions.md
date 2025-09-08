# Docker Permissions Management

## Principe fondamental

**TOUJOURS exporter UID/GID avant de lancer des commandes Docker** pour éviter les problèmes de permissions entre le host et les containers.

## Commandes Docker directes

### Export obligatoire avant Docker commands

```bash
# Export UID/GID avant toute commande Docker
# UID est déjà défini en bash, il suffit de l'exporter
export UID
export GID=$(id -g)

# Maintenant les commandes Docker respectent les permissions
docker compose up -d
docker compose build
docker compose exec app sh
```

### Exemples d'usage Claude Code

```bash
# ✅ BON - Export UID/GID avant Docker
export UID && export GID=$(id -g) && docker compose up -d

# ✅ BON - En plusieurs lignes  
export UID
export GID=$(id -g) 
docker compose build

# ✅ BON - Une seule ligne
export UID GID=$(id -g)
docker compose up -d

# ❌ MAUVAIS - Docker sans export UID/GID
docker compose up -d  # Risque de problèmes de permissions
```

## Dans les scripts bash

### Pattern recommandé

```bash
#!/bin/bash
set -e

# Export UID/GID en début de script
# UID est déjà défini, il suffit de l'exporter
export UID
export GID=$(id -g)

# Maintenant tous les appels Docker fonctionnent correctement
docker compose build
docker compose up -d
docker compose exec app npm install
```

### Dans les fonctions

```bash
run_docker_command() {
    # Export UID (déjà défini) et GID
    export UID
    export GID=$(id -g)
    
    docker compose "$@"
}
```

## Avec Claude Code agents

### Pour tous les agents utilisant Docker

```bash
# Pattern standard pour agents Claude Code
export_docker_permissions() {
    export UID
    export GID=$(id -g)
    echo "✅ Docker permissions set: UID=$UID, GID=$GID"
}

# Appeler avant toute commande Docker
export_docker_permissions
docker compose up -d
```

## docker-compose.yml Pattern

### Services avec UID/GID Args

```yaml
services:
  app:
    build:
      context: .
      args:
        UID: ${UID:-1000}    # Fallback si pas d'export
        GID: ${GID:-1000}    # Fallback si pas d'export
    user: ${UID:-1000}:${GID:-1000}
    volumes:
      - .:/app
```

### Dockerfile Pattern

```dockerfile
# Récupération des arguments de build
ARG UID=1000
ARG GID=1000

# Application des permissions
RUN groupmod -g ${GID} www-data \
    && usermod -u ${UID} -g ${GID} www-data

USER www-data
```

## Makefile Integration

### Auto-export dans Makefile

```make
# Auto-export pour toutes les commandes make
export UID := $(shell id -u)
export GID := $(shell id -g)

dev: ## Start development environment
	docker compose up -d

shell: ## Enter container
	docker compose exec app sh
```

## Cas d'usage Claude Code

### 1. Test runner agent

```bash
# Export permissions avant tests
export UID && export GID=$(id -g)
docker compose exec app npm test
```

### 2. Code analysis agent  

```bash
# Export permissions pour linters
export UID && export GID=$(id -g)
docker compose --profile tools up -d linter
docker compose exec linter eslint src/
```

### 3. Development setup agent

```bash
# Export permissions pour setup initial
export UID && export GID=$(id -g)
docker compose build
docker compose up -d
docker compose exec app composer install
```

### 4. Quick shell access to main app container

```bash
# Access main application container (web service) quickly
export UID && export GID=$(id -g)
docker compose exec app sh

# Or use convenient Makefile target
make sh    # Enters the container running your web application
```

## Debugging permissions

### Vérifier les permissions dans container

```bash
export UID && export GID=$(id -g)
docker compose exec app id
# Devrait afficher le même UID/GID que sur host
```

### Vérifier ownership des fichiers

```bash
# Sur host
ls -la

# Dans container (devrait matcher)
export UID && export GID=$(id -g)
docker compose exec app ls -la /app
```

## Règles pour Claude Code

1. **ALWAYS export UID/GID** avant les commandes Docker
2. **Use single line** pour les commandes simples : `export UID && export GID=$(id -g) && docker compose up`
3. **Use multi-line** pour les scripts complexes
4. **Check permissions** si problèmes de fichiers created par containers
5. **Fallback values** dans docker-compose.yml (1000:1000) pour compatibilité

## Pattern universel

```bash
# Pattern à utiliser dans tous les contextes Claude Code
export UID && export GID=$(id -g) && docker compose [command]
```

Cette approche garantit **zéro problème de permissions** avec Docker sur tous les systèmes Unix.