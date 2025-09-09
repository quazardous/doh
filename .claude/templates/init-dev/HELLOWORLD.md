# Hello World Testing - DOH Stack Validation

This document explains the Hello World testing principle used to validate generated development stacks in the DOH (Docker + Outils + Hello-world) system.

## Hello World Testing Principle

### Purpose
The Hello World test validates that the entire generated stack is functional:
- **Framework Integration** - Backend framework correctly installed and running
- **Database Connectivity** - Database connection works
- **Frontend Integration** - Frontend can communicate with backend (if applicable)
- **Environment Variables** - Configuration properly loaded
- **SSL/Routing** - Traefik routing and SSL certificates working
- **DOH Hash Verification** - Stack-specific validation token

### Validation Steps

#### Container Connectivity Test
Verify that the app container can be accessed and basic commands work:
- **Container Access**: `docker compose exec app ls` → Directory listing works
- **Container Shell**: `docker compose exec app bash` → Interactive shell accessible
- **Container Process**: `docker compose run --rm app sleep infinity` → Container stays up
- **File System**: Volume mounts functional and permissions correct

#### Framework Native Hello World
Execute the framework's standard hello world:
- **Django**: `python manage.py runserver` → "Django welcome page"
- **Laravel**: `php artisan serve` → "Laravel welcome page"  
- **Express**: `npm start` → "Express server running"
- **Rails**: `rails server` → "Rails welcome page"

#### DOH Hello World with Hash Verification
Execute DOH-specific validation with `DOH_HELLOWORLD` hash:
- **Console Test**: Framework CLI command displays DOH_HELLOWORLD value
- **Web Test**: HTTPS endpoint returns JSON with DOH_HELLOWORLD value
- **Full Stack Test**: Database connection + SSL + routing functional

## Implementation Patterns by Framework

### Django Hello World
```bash
# Container connectivity test
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app ls -la /app

# Framework native test
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app python manage.py runserver 0.0.0.0:8000
# → Django welcome page at https://app.{PROJECT_NAME}.localhost

# DOH validation test  
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app python manage.py shell -c "
from django.conf import settings
print('DOH_HELLOWORLD:', getattr(settings, 'DOH_HELLOWORLD', 'NOT_SET'))
"

# Web endpoint test
curl -k https://app.{PROJECT_NAME}.localhost/doh-hello
# → {"doh_helloworld": "abc123...", "framework": "Django", "database": "connected"}
```

### Laravel Hello World
```bash
# Container connectivity test
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app ls -la /app

# Framework native test
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app php artisan serve --host=0.0.0.0 --port=8000
# → Laravel welcome page

# DOH validation test
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app php artisan tinker --execute="echo 'DOH_HELLOWORLD: ' . env('DOH_HELLOWORLD', 'NOT_SET');"

# Web endpoint test  
curl -k https://app.{PROJECT_NAME}.localhost/doh-hello
# → {"doh_helloworld": "abc123...", "framework": "Laravel", "database": "connected"}
```

### Express/Node.js Hello World
```bash
# Container connectivity test
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app ls -la /app

# Framework native test
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app npm start
# → Express server at https://app.{PROJECT_NAME}.localhost

# DOH validation test
export UID && export GID=$(id -g) && docker compose --env-file docker-compose.env exec app node -e "console.log('DOH_HELLOWORLD:', process.env.DOH_HELLOWORLD || 'NOT_SET')"

# Web endpoint test
curl -k https://app.{PROJECT_NAME}.localhost/doh-hello
# → {"doh_helloworld": "abc123...", "framework": "Express", "database": "connected"}
```

## DOH_HELLOWORLD Hash Generation

### Hash Format
```bash
# Generated during stack creation
DOH_HELLOWORLD=$(echo "doh-$(date +%Y%m%d)-${PROJECT_NAME}-${FRAMEWORK}" | sha256sum | cut -d' ' -f1 | head -c16)
# Example: DOH_HELLOWORLD=f4a7b2c8e9d1a6f3
```

### Environment Variable Injection
```bash
# .env file
DOH_HELLOWORLD=f4a7b2c8e9d1a6f3
```

### Framework-Specific Access Patterns
- **Django**: `settings.DOH_HELLOWORLD`
- **Laravel**: `env('DOH_HELLOWORLD')`
- **Express**: `process.env.DOH_HELLOWORLD`
- **Rails**: `ENV['DOH_HELLOWORLD']`
- **Symfony**: `$_ENV['DOH_HELLOWORLD']`

## Web Endpoint Implementation

### Standard DOH Hello Endpoint
All frameworks must implement `/doh-hello` endpoint:

```json
{
  "doh_helloworld": "f4a7b2c8e9d1a6f3",
  "framework": "Django",
  "framework_version": "5.0.0",
  "database": "connected|error",
  "database_type": "mariadb",
  "frontend": "vue3|react|none",
  "ssl": "valid",
  "timestamp": "2024-01-15T10:30:00Z",
  "stack_status": "healthy"
}
```

### Validation Checks
The endpoint performs comprehensive stack validation:
1. **Environment Check** - DOH_HELLOWORLD value present and correct
2. **Database Check** - Connection test and simple query
3. **Framework Check** - Framework-specific health indicators
4. **SSL Check** - HTTPS request successful
5. **Frontend Check** - Frontend build assets accessible (if applicable)

## Testing Integration with Makefile

### Hello World Targets
```makefile
# Container connectivity test
hello-container:
	@echo "Testing container connectivity..."
	$(RUN_APP) ls -la /app
	@echo "Container shell test..."
	$(RUN_APP) echo "Container connectivity: OK"

# Framework native hello world
hello:
	@echo "Testing framework native hello world..."
	$(RUN_APP) {framework-specific-command}

# DOH validation hello world  
hello-doh:
	@echo "Testing DOH stack validation..."
	$(RUN_APP) {framework-specific-doh-command}
	@echo "Web endpoint test..."
	curl -k -s https://app.$(PROJECT_NAME).localhost/doh-hello | jq .

# Complete validation
validate-stack: hello-container hello hello-doh
	@echo "✅ Stack validation complete"
```

### Framework-Specific Makefile Targets

#### Django
```makefile
hello-container:
	@echo "Testing Django container connectivity..."
	$(RUN_APP) ls -la /app
	$(RUN_APP) echo "Django container connectivity: OK"

hello:
	@echo "Testing Django native hello world..."
	$(RUN_APP) python manage.py runserver 0.0.0.0:8000 --noreload &
	@sleep 5 && curl -s https://app.$(PROJECT_NAME).localhost/ | grep -q "Django"

hello-doh:
	@echo "Testing Django DOH validation..."
	$(RUN_APP) python manage.py shell -c "from django.conf import settings; print('DOH_HELLOWORLD:', settings.DOH_HELLOWORLD)"
	@curl -k -s https://app.$(PROJECT_NAME).localhost/doh-hello | jq .doh_helloworld
```

#### Laravel
```makefile
hello-container:
	@echo "Testing Laravel container connectivity..."
	$(RUN_APP) ls -la /app
	$(RUN_APP) echo "Laravel container connectivity: OK"

hello:
	@echo "Testing Laravel native hello world..."
	$(RUN_APP) php artisan serve --host=0.0.0.0 --port=8000 &
	@sleep 5 && curl -s https://app.$(PROJECT_NAME).localhost/ | grep -q "Laravel"

hello-doh:
	@echo "Testing Laravel DOH validation..."
	$(RUN_APP) php artisan tinker --execute="echo env('DOH_HELLOWORLD');"
	@curl -k -s https://app.$(PROJECT_NAME).localhost/doh-hello | jq .doh_helloworld
```

## Error Patterns and Debugging

### Common Hello World Failures

**Container connectivity failed:**
```bash
# Check container access
$(RUN_APP) ls -la /app
$(RUN_APP) echo "Container test"
# → Should work without errors
```

**DOH_HELLOWORLD not found:**
```bash
# Check environment variable loading
$(RUN_APP) env | grep DOH_HELLOWORLD
# → Should show: DOH_HELLOWORLD=f4a7b2c8e9d1a6f3
```

**Database connection failed:**
```bash
# Test database connectivity
$(RUN_APP) {framework-db-test-command}
# Django: python manage.py dbshell
# Laravel: php artisan tinker --execute="DB::connection()->getPdo();"
```

**SSL/Routing failed:**
```bash
# Check Traefik routing
curl -k https://app.$(PROJECT_NAME).localhost/
# Check SSL certificates
make ssl-setup
```

**Frontend integration failed:**
```bash
# Check frontend build
$(RUN_APP) {frontend-build-command}
# npm run build / yarn build
```

### Debugging Commands
```bash
# Complete stack health check
make validate-stack

# Individual component tests
make hello-container # Container connectivity  
make hello          # Framework native
make hello-doh      # DOH validation  
make ssl-setup      # SSL certificates
make logs           # View all logs
```

## Integration with Kitchen Process

### Step 17: Test Container Connectivity
- Verify basic container access and shell functionality
- Test volume mounts and file system permissions
- Confirm container can stay up with background processes

### Step 18: Test Official HelloWorld
- Use framework's native hello world test
- Verify basic framework functionality
- Validate development server starts correctly

### Step 19: Test Hello-DOH Validation
- Generate DOH_HELLOWORLD hash
- Test console DOH hash display
- Test web endpoint DOH validation
- Verify complete stack functionality

### Success Criteria
✅ Container connectivity works (Phase 0)
✅ Framework native hello world works (Phase 1)
✅ DOH_HELLOWORLD hash generated and accessible (Phase 2)
✅ Console test displays correct hash
✅ Web endpoint returns valid JSON with hash
✅ Database connection successful
✅ SSL certificates valid
✅ Traefik routing functional
✅ Frontend integration working (if applicable)

---

**The Hello World test is the final validation that confirms the entire generated stack is ready for development.**