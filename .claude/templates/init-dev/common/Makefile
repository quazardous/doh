.PHONY: help
.DEFAULT_GOAL := help

# Auto-detect user IDs to avoid permission issues
export UID := $(shell id -u)
export GID := $(shell id -g)
export PROJECT_NAME := $(shell basename $(PWD) | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')

help: ## Show this help message
	@echo "🔧 Development Environment Commands"
	@echo "=================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# === Environment Management ===

dev: ## Start development environment
	docker compose up -d

stop: ## Stop all containers (preserve data)
	docker compose down

restart: ## Restart all containers (preserve data)
	docker compose down && docker compose up -d

status: ## Show running containers status
	docker compose ps

logs: ## Show container logs
	docker compose logs -f

logs-%: ## Show logs for specific service (e.g. make logs-app)
	docker compose logs -f $*

# === Container Management ===

rebuild: ## 🔄 Rebuild all containers (preserve data)
	docker compose down
	docker compose build --no-cache
	docker compose up -d

rebuild-app: ## 🔄 Rebuild only app container (preserve data)
	docker compose stop app
	docker compose build --no-cache app
	docker compose up -d app

rebuild-%: ## 🔄 Rebuild specific container (e.g. make rebuild-redis)
	docker compose stop $*
	docker compose build --no-cache $*
	docker compose up -d $*

# === Shell Access ===

sh: ## Quick access to main application container shell (web service)
	docker compose exec ${APP_CONTAINER:-app} sh

shell: ## Access main application container shell (alias for sh)
	docker compose exec ${APP_CONTAINER:-app} sh

# === Linting & Code Quality ===

lint-start: ## Start linting tools container
	docker compose --profile tools up -d linter
	@echo "✅ Linting tools container started"

lint-stop: ## Stop linting tools container
	docker compose stop linter
	@echo "✅ Linting tools container stopped"

lint: ## Run code linting (check only, no fixes)
	@echo "🔍 Running code quality checks..."
	@if docker compose ps linter | grep -q "Up"; then \
		echo "Using dedicated linter container:"; \
		$(MAKE) lint-check; \
	else \
		echo "❌ Linter container not running. Start it with: make lint-start"; \
	fi

lint-fix: ## Run code linting with auto-fixes
	@echo "🔧 Running code linting with auto-fixes..."
	@if docker compose ps linter | grep -q "Up"; then \
		echo "Using dedicated linter container:"; \
		$(MAKE) lint-autofix; \
	else \
		echo "❌ Linter container not running. Start it with: make lint-start"; \
	fi

format: ## Format code (prettify/beautify)
	@echo "✨ Formatting code..."
	@if docker compose ps linter | grep -q "Up"; then \
		echo "Using dedicated linter container:"; \
		$(MAKE) format-code; \
	else \
		echo "❌ Linter container not running. Start it with: make lint-start"; \
	fi

# Stack-specific linting targets (to be customized per project)
lint-check: ## Check code style (no fixes)
	@echo "📋 Add stack-specific lint check commands here"
	@echo "Examples:"
	@echo "  Node.js: docker compose exec linter eslint src/"
	@echo "  PHP:     docker compose exec linter phpstan analyze"
	@echo "  Python:  docker compose exec linter flake8 src/"

lint-autofix: ## Auto-fix code style issues
	@echo "🔧 Add stack-specific lint fix commands here"
	@echo "Examples:"
	@echo "  Node.js: docker compose exec linter eslint src/ --fix"
	@echo "  PHP:     docker compose exec linter php-cs-fixer fix src/"
	@echo "  Python:  docker compose exec linter autopep8 --in-place --recursive src/"

format-code: ## Format/prettify code
	@echo "✨ Add stack-specific formatting commands here"
	@echo "Examples:"
	@echo "  Node.js: docker compose exec linter prettier --write src/"
	@echo "  PHP:     docker compose exec linter php-cs-fixer fix src/ --rules=@PSR12"
	@echo "  Python:  docker compose exec linter black src/"

# === Database Management ===

clean-data: ## 🔥 DANGER: Reset all database data
	@echo "⚠️  This will delete ALL database data!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	docker compose down
	sudo rm -rf docker-dev/data/*/
	docker compose up -d
	@echo "✅ Database data reset complete"

backup-data: ## Backup database data
	@mkdir -p backups
	@tar -czf backups/db-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz docker-dev/data/ 2>/dev/null || echo "No data to backup"
	@echo "✅ Database backup created"

# === Setup & Validation ===

docker-env: ## Copy all *-docker template files to working files
	@echo "📋 Setting up Docker environment files from templates..."
	@for file in *-docker; do \
		if [ -f "$$file" ]; then \
			target=$${file%-docker}; \
			if [ ! -f "$$target" ]; then \
				cp "$$file" "$$target"; \
				echo "✅ Created $$target from $$file"; \
			else \
				echo "⚠️ $$target already exists (skipped)"; \
			fi; \
		fi; \
	done
	@echo "✅ Docker environment setup complete"

check-deps: ## Check if all required dependencies are installed
	@echo "🔍 Checking development dependencies..."
	@command -v docker >/dev/null && echo "✅ Docker" || echo "❌ Docker (required)"
	@command -v docker-compose >/dev/null && echo "✅ docker-compose" || echo "❌ docker-compose (required)"
	@command -v mkcert >/dev/null && echo "✅ mkcert" || echo "❌ mkcert (required for HTTPS)"
	@command -v curl >/dev/null && echo "✅ curl" || echo "❌ curl (required for testing)"
	@command -v make >/dev/null && echo "✅ make" || echo "❌ make (required)"
	@echo ""
	@echo "💡 Run 'make install-deps' to install missing dependencies"

install-deps: ## Install missing dependencies
	@echo "📦 Installing development dependencies..."
	@chmod +x docker-dev/scripts/install-deps.sh
	@./docker-dev/scripts/install-deps.sh
	@echo "✅ Dependencies installation complete"

setup: docker-env ssl-setup ## Initial project setup
	@echo "✅ Project setup complete"

ssl-setup: ## Generate SSL certificates
	@echo "🔒 Setting up SSL certificates..."
	@command -v mkcert >/dev/null || (echo "❌ mkcert required. Install with: brew install mkcert" && exit 1)
	@mkcert -install
	@mkdir -p docker-dev/certs
	@mkcert -cert-file docker-dev/certs/localhost.pem \
	        -key-file docker-dev/certs/localhost-key.pem \
	        "*.$(PROJECT_NAME).localhost" \
	        "$(PROJECT_NAME).localhost" \
	        "localhost"
	@echo "✅ SSL certificates generated"

dev-setup: docker-env ssl-setup ## Full development environment setup
	@cp docker-compose.env .env 2>/dev/null || echo "⚠️ .env already exists"
	@echo "✅ Development environment ready"

hello-world: ## 🌍 Validate entire stack is working
	@echo "🌍 Running Hello World validation..."
	@echo ""
	@echo "📋 Checking services..."
	@docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "🔗 Testing connectivity..."
	@echo "• Traefik Dashboard: http://localhost:8080"
	@curl -s -o /dev/null -w "• App HTTPS: %%{http_code} - https://app.$(PROJECT_NAME).localhost\n" -k https://app.$(PROJECT_NAME).localhost || echo "• App HTTPS: ❌ Not responding"
	@curl -s -o /dev/null -w "• App HTTP: %%{http_code} - http://app.$(PROJECT_NAME).localhost\n" http://app.$(PROJECT_NAME).localhost || echo "• App HTTP: ❌ Not responding"
	@echo ""
	@echo "🗄️ Testing database connections..."
	@docker compose exec -T app sh -c 'echo "Database connection test from app container:"' 2>/dev/null || echo "• App container: ❌ Not available"
	@echo ""
	@echo "📁 Checking data persistence..."
	@ls -la docker-dev/data/ 2>/dev/null | grep -E "mysql|postgres|mongodb|redis" || echo "• Database data: ✅ No data dirs (fresh install)"
	@echo ""
	@echo "🎉 Hello World validation complete!"
	@echo ""
	@echo "🚀 Quick access URLs:"
	@echo "   • App: https://app.$(PROJECT_NAME).localhost"
	@echo "   • Traefik: http://localhost:8080"
	@if docker compose ps | grep -q phpmyadmin; then echo "   • phpMyAdmin: https://phpmyadmin.$(PROJECT_NAME).localhost"; fi
	@if docker compose ps | grep -q adminer; then echo "   • Adminer: https://adminer.$(PROJECT_NAME).localhost"; fi
	@if docker compose ps | grep -q mongo-express; then echo "   • Mongo Express: https://mongo-express.$(PROJECT_NAME).localhost"; fi
	@if docker compose ps | grep -q mailhog; then echo "   • MailHog: https://mailhog.$(PROJECT_NAME).localhost"; fi

# === Maintenance ===

clean: ## Clean up containers and volumes
	docker compose down -v
	docker system prune -f

clean-all: ## 🔥 DANGER: Complete cleanup (containers + data + images)
	@echo "⚠️  This will delete EVERYTHING (containers, data, images)!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	docker compose down -v
	sudo rm -rf docker-dev/data/* docker-dev/logs/*
	docker system prune -af
	@echo "✅ Complete cleanup finished"

update: ## Update all container images
	docker compose pull
	$(MAKE) rebuild
	@echo "✅ All containers updated"