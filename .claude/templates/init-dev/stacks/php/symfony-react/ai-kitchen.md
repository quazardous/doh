# Symfony React AI-Kitchen Instructions

## Stack Overview

**Symfony + React + MariaDB** - Full-stack PHP development with modern React frontend and database.

### Technology Detection Patterns
- **Framework**: Symfony (composer.json with symfony/framework-bundle)
- **Frontend**: React (package.json with react, webpack-encore)  
- **Database**: MariaDB (user choice or statistical pairing)
- **Package Manager**: Yarn (detected from yarn.lock or user specification)

### Generated Structure
```
project-name/
├── src/                    # Symfony application source
├── public/                 # Web document root  
├── assets/                 # React frontend assets
├── config/                 # Symfony configuration
├── var/                    # Logs, cache, runtime data
├── docker/                 # Container configuration
│   ├── app/               # PHP 8.3 + Node.js 20 + Nginx
│   ├── mariadb/           # Database configuration
│   └── traefik/           # SSL reverse proxy
└── Makefile               # Development commands
```

## AI-Kitchen Processing Instructions

### @AI-Kitchen: SUBSTITUTE - Symfony React Variables
- `{{PROJECT_NAME}}` → Actual project name (lowercase, sanitized)
- `{{SYMFONY_VERSION}}` → Latest stable (7.1.x)
- `{{PHP_VERSION}}` → PHP 8.3 (LTS with Symfony 7.1)
- `{{NODE_VERSION}}` → Node.js 20 LTS
- `{{MARIADB_VERSION}}` → MariaDB 12.x (latest stable)

### @AI-Kitchen: CONDITIONAL - Stack Detection
- **IF React detected**: Include Webpack Encore bundle, Node.js tools
- **IF MariaDB chosen**: Include Doctrine DBAL, DoctrineBundle
- **IF development**: Include Maker Bundle, profiler, debug toolbar

### @AI-Kitchen: MERGE - Configuration Files
Merge base templates with Symfony-specific configurations:

**docker-compose.yml**:
- Base app service + Symfony environment variables
- MariaDB service + phpMyAdmin
- Traefik with Symfony routing labels

**Makefile**:
- Base seed targets + Symfony console commands
- Composer + Yarn dependency management
- Symfony makers (make:controller, make:entity)

## Hello World Implementation

### @AI-Kitchen: GENERATE - Use Symfony Makers

**Phase 1: Create Hello World Controller**
```bash
# Generate controller with Symfony maker (via Docker container)
make sh  # Enter the app container
php bin/console make:controller HelloController
# Or directly: docker exec -it ${APP_CONTAINER} php bin/console make:controller HelloController

# Then modify the generated controller to add:
# - /hello endpoint with basic stack info
# - /hello-doh endpoint with DOH validation hash
# - /health endpoint for monitoring
```

**Phase 2: Create Hello World CLI Command**
```bash  
# Generate console command with Symfony maker (via Docker container)
make sh  # Enter the app container
php bin/console make:command app:hello
# Or directly: docker exec -it ${APP_CONTAINER} php bin/console make:command app:hello

# Then modify the generated command to add:
# - DOH validation hash check
# - Database connectivity test  
# - Stack status summary
# - HTTP endpoint internal test
```

**Code to add in generated HelloController:**
```php
#[Route('/hello', name: 'app_hello')]
public function index(): Response
{
    return $this->json([
        'message' => 'Hello from Symfony React!',
        'framework' => 'Symfony 7.1',
        'database' => 'MariaDB',
        'frontend' => 'React',
        'timestamp' => date('c')
    ]);
}

#[Route('/hello-doh', name: 'app_hello_doh')]
public function helloDoh(): Response
{
    // Test database connectivity
    try {
        $connection = $this->container->get('doctrine')->getConnection();
        $connection->executeQuery('SELECT 1');
        $dbStatus = 'connected';
    } catch (\Exception $e) {
        $dbStatus = 'error';
    }

    return $this->json([
        'message' => 'DOH Kitchen Symfony React Stack Ready!',
        'validation_hash' => $_ENV['DOH_HELLOWORLD'] ?? 'missing',
        'stack' => [
            'framework' => 'Symfony 7.1',
            'php_version' => PHP_VERSION,
            'database' => 'MariaDB 12',
            'database_status' => $dbStatus,
            'frontend' => 'React 18',
            'ssl' => 'Traefik HTTPS'
        ],
        'timestamp' => date('c')
    ]);
}
```

**Code to add in generated HelloCommand:**
```php
protected function execute(InputInterface $input, OutputInterface $output): int
{
    $io = new SymfonyStyle($input, $output);
    
    $io->title('⚛️ DOH Kitchen - Symfony React Stack Validation');
    
    // DOH validation hash
    $hash = $_ENV['DOH_HELLOWORLD'] ?? 'missing';
    $io->success('✅ DOH validation: ' . $hash);
    
    // Database test
    try {
        $connection = $this->container->get('doctrine')->getConnection();
        $connection->executeQuery('SELECT VERSION()');
        $io->success('✅ MariaDB: Connected');
    } catch (\Exception $e) {
        $io->error('❌ MariaDB: ' . $e->getMessage());
        return Command::FAILURE;
    }
    
    // HTTP endpoint test
    $response = file_get_contents('http://localhost:8000/hello');
    if ($response) {
        $io->success('✅ HTTP: Responding');
    } else {
        $io->warning('⚠️  HTTP: Not responding');
    }
    
    $io->success('Symfony React stack validation completed!');
    return Command::SUCCESS;
}
```

## Web Server Configuration

### @AI-Kitchen: GENERATE - Nginx Configuration
```nginx
# docker/app/nginx.conf
server {
    listen 8000;
    server_name _;
    root /app/public;
    index index.php;

    # Symfony rewrite rules
    location / {
        try_files $uri /index.php$is_args$args;
    }

    # PHP-FPM configuration  
    location ~ ^/index\.php(/|$) {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        
        internal;
    }

    # Deny other PHP files
    location ~ \.php$ {
        return 404;
    }
}
```

### @AI-Kitchen: GENERATE - Supervisord Configuration
```ini
# docker/app/supervisord.conf
[supervisord]
nodaemon=true
user=appuser

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true
user=appuser

[program:php-fpm]
command=/usr/local/sbin/php-fpm -F
autostart=true
autorestart=true
user=appuser

[program:react-dev]
command=yarn start
directory=/app
autostart=false
autorestart=true
user=appuser
environment=NODE_ENV="development"
```

## Validation Commands

### @AI-Kitchen: GENERATE - Make Targets  
Update the `hello-doh` target in Makefile.symfony-react-part:
```makefile
hello-doh: ## Symfony React Hello World + DOH validation
	@echo "⚛️ Creating Symfony React Hello World..."
	@echo "📋 Command: $(SYMFONY_CONSOLE) make:controller HelloController --no-template"
	@$(SYMFONY_CONSOLE) make:controller HelloController --no-template
	@echo "📋 Command: $(SYMFONY_CONSOLE) make:command app:hello"  
	@$(SYMFONY_CONSOLE) make:command app:hello
	@echo "🤖 AI should now modify the generated files with the validation code"
	@echo "✅ Testing HTTP endpoint..."
	@${EXEC_CONTAINER} ${APP_CONTAINER} curl http://localhost:8000/hello-doh || echo "⚠️ HTTP test failed (may be normal if not fully started)"
	@echo "✅ Testing CLI command..."
	@$(SYMFONY_CONSOLE) app:hello

symfony-test: ## Test Symfony + database connectivity  
	@echo "🗄️ Testing database connection..."
	@echo "📋 Command: $(SYMFONY_CONSOLE) dbal:run-sql \"SELECT 1\""
	@$(SYMFONY_CONSOLE) dbal:run-sql "SELECT 1" || echo "⚠️ Database test failed"
	@echo "⚛️ Testing Webpack Encore React..."
	@echo "📋 Command: ${EXEC_CONTAINER} ${APP_CONTAINER} yarn build"
	@${EXEC_CONTAINER} ${APP_CONTAINER} yarn build || echo "⚠️ Frontend build failed"
```

## Environment Configuration

### @AI-Kitchen: SUBSTITUTE - Environment Variables
```bash
# .env (Symfony application)
APP_ENV=dev
APP_SECRET=generated-secret-key
DATABASE_URL="mysql://{{PROJECT_NAME}}:{{PROJECT_NAME}}@mariadb:3306/{{PROJECT_NAME}}?serverVersion=mariadb-12.0.2"
MAILER_DSN=null://null
DOH_HELLOWORLD={{DOH_VALIDATION_HASH}}

# docker-compose.env (Container configuration)  
PROJECT_NAME={{PROJECT_NAME}}
SYMFONY_VERSION=7.1
PHP_VERSION=8.3
MARIADB_DATABASE={{PROJECT_NAME}}
MARIADB_USER={{PROJECT_NAME}}
MARIADB_PASSWORD={{PROJECT_NAME}}
```

## Dependencies Configuration

### @AI-Kitchen: GENERATE - composer.json
```json
{
    "require": {
        "php": ">=8.3",
        "symfony/framework-bundle": "7.1.*",
        "symfony/console": "7.1.*",
        "symfony/dotenv": "7.1.*",
        "symfony/yaml": "7.1.*",
        "symfony/webpack-encore-bundle": "^2.0",
        "doctrine/doctrine-bundle": "^2.12",
        "doctrine/orm": "^3.0"
    },
    "require-dev": {
        "symfony/maker-bundle": "^1.0",
        "phpunit/phpunit": "^11.0"
    }
}
```

### @AI-Kitchen: GENERATE - package.json
```json
{
    "devDependencies": {
        "@symfony/webpack-encore": "^4.0.0",
        "react": "^18.2.0",
        "react-dom": "^18.2.0",
        "@babel/preset-react": "^7.18.6"
    },
    "scripts": {
        "start": "encore dev --watch",
        "build": "encore production"
    }
}
```

## Kitchen Success Criteria

✅ **Symfony application responds** at `/hello` endpoint  
✅ **DOH validation** returns correct hash at `/hello-doh`  
✅ **CLI command works** with `php bin/console app:hello`  
✅ **Database connectivity** via Doctrine  
✅ **React compilation** with Webpack Encore  
✅ **SSL certificates** functional via Traefik  
✅ **Process management** with Nginx + PHP-FPM + supervisord

## Troubleshooting

**Common Symfony React issues:**
- **500 errors**: Check `var/log/dev.log` for Symfony errors
- **Database errors**: Verify MariaDB credentials in `.env`
- **Permission issues**: Check `var/` directory permissions (UID/GID mapping)
- **Assets not loading**: Run `yarn build` or `yarn start` via Docker
- **Command not found**: All Symfony commands must run inside Docker container

**Container debugging (all commands via Docker):**
```bash
# Enter the container for debugging
make sh

# Inside container - test HTTP endpoints
curl http://localhost:8000/hello
curl http://localhost:8000/hello-doh

# Inside container - Symfony debugging commands
php bin/console debug:config
php bin/console debug:router
php bin/console debug:container
php bin/console debug:env

# Inside container - database debugging  
php bin/console dbal:run-sql "SHOW TABLES"
mysql -h mariadb -u ${PROJECT_NAME} -p

# Inside container - frontend debugging
yarn --version
yarn build
yarn start

# Process debugging
ps aux | grep nginx
ps aux | grep php-fpm
supervisorctl status
```

**Direct Docker commands (if make not available):**
```bash
# Run Symfony console commands
docker exec -it ${APP_CONTAINER} php bin/console cache:clear
docker exec -it ${APP_CONTAINER} php bin/console make:controller TestController

# Check container logs
docker logs ${APP_CONTAINER}
docker exec -it ${APP_CONTAINER} tail -f var/log/dev.log

# Test connectivity
docker exec -it ${APP_CONTAINER} curl http://localhost:8000/hello
docker exec -it ${APP_CONTAINER} ping mariadb
```