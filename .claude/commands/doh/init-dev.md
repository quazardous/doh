---
allowed-tools: Bash, Glob, Grep, LS, Read, Write, Edit, MultiEdit, WebFetch
---

# Initialize Development Stack - AI-Driven Stack Creation

Creates a modern, pragmatic development environment by analyzing requested stack and cherry-picking from DOH templates. Uses web research to discover current best practices for the specific stack and translates them into DOH-compliant Docker setup.

## Usage
```
/doh:init-dev <natural language stack description>
/doh:init-dev "Python Django with PostgreSQL in ./docker directory"  
/doh:init-dev "Node.js React fullstack with MySQL and Redis"
/doh:init-dev "PHP Laravel API with PostgreSQL and background jobs"
/doh:init-dev "Python FastAPI microservice with MongoDB"
```

## AI-Driven Approach

This command is **AI-piloted**, not scripted, because each stack has unique requirements and evolving best practices:

### 1. Stack Analysis (Detection vs Manual)

**Manual Mode** (`/doh:init-dev "Python Django..."`):
- Parse natural language description  
- Identify components from user input

**Detection Mode** (`/doh:init-dev --detect`):
- **File Analysis:** Examine existing project files for technology indicators
  ```text
  package.json → Node.js/JavaScript stack
  requirements.txt → Python stack  
  composer.json → PHP stack
  Cargo.toml → Rust stack
  go.mod → Go stack
  ```
- **Dependency Analysis:** Parse dependency files for framework detection
  ```text
  Django in requirements.txt → Django framework
  express in package.json → Express.js framework
  laravel/framework in composer.json → Laravel framework
  ```
- **README Analysis:** Extract technology mentions and setup instructions
- **Existing Docker Analysis:** Check current docker-compose.yml for services
- **Database Detection:** Look for database connection configs and migrations

### 2. Cherry-Pick from Templates
- Analyze `.claude/templates/init-dev/` for relevant inspiration
- Select appropriate base templates (common/, stacks/, services/)
- Adapt template patterns to detected/requested stack

### 3. Research Current Best Practices  
- Use WebSearch to find latest recommendations for the specific stack
- Identify de-facto standard linters and testing tools
- Discover current version constraints and compatibility issues

### 4. Translate to DOH Patterns
- Apply DOH principles (Docker + Traefik + mkcert + Hello World)
- Ensure zero permission issues (UID/GID matching)
- Create project-specific service selection
- Generate working Hello World for validation

### Directory Customization
- User can specify directory: "in ./docker" → creates files in `./docker/`
- Default: `./docker-dev/` (DOH standard)
- Respects user preference while maintaining DOH patterns

## Core Philosophy

### Docker-Focused & Pragmatic
- **Docker as standard** unless explicitly contraindicated
- **Realistic containers** - avoid over-containerization
- **Multi-project friendly** - `{service}.{project}.local` domains
- **Linting containers** - Separate linter containers to avoid version conflicts

### Template-Based Generation
- Uses templates from `.claude/templates/init-dev/`
- **Templates are illustrations** - versions and configs adapted at runtime
- Fetches current versions from official APIs
- Modular template system for stacks and services

## Implementation Workflow

### 1. Analyze Request & Research Stack

**Natural Language Processing:**
```text
Input: "Python Django with PostgreSQL in ./docker directory"
→ Stack: Python + Django  
→ Database: PostgreSQL
→ Directory: ./docker/
→ Inferred needs: Web framework + ORM + Database + Testing + Linting
```

**AI-Driven Research:**
- WebSearch: "Django 2024 best practices development setup"
- WebSearch: "Python Django recommended linters 2024" 
- WebSearch: "Django testing tools pytest vs unittest"
- WebSearch: "Django Docker production-ready setup"

**Template Cherry-Picking:**
- Select from `.claude/templates/init-dev/stacks/python/`
- Check `.claude/templates/init-dev/services/postgres.yml`
- Adapt `.claude/templates/init-dev/common/Makefile` for Django-specific commands

### 2. Generate Stack-Specific Configuration

**AI Decision Making:**
- Based on research, select optimal linters: `black`, `flake8`, `mypy`, `isort`
- Choose testing framework: `pytest` (most popular in 2024)
- Determine Django version compatibility with Python version
- Select appropriate database client and ORM migrations strategy

**Dynamic Template Processing:**
```text
Template Pattern → Generated Reality
{{PROJECT_NAME}} → django-blog-api
{{PYTHON_VERSION}} → 3.12-slim (latest stable)
{{DJANGO_VERSION}} → 5.0 (from research)
{{DB_SERVICE}} → postgres (user specified)
{{DIRECTORY}} → ./docker/ (user specified)
```

### 3. Create DOH-Compliant Stack

**Essential Components (Always):**
- ✅ Docker Compose with Traefik routing
- ✅ SSL certificates via mkcert 
- ✅ UID/GID permission matching
- ✅ Multi-project domain pattern: `app.{project}.local`
- ✅ Makefile with `dev`, `sh`, `hello-world` targets
- ✅ Working Hello World endpoint + console command

**Stack-Specific Components:**
- ✅ Linter container with discovered best-practice tools
- ✅ Testing framework setup with sample test
- ✅ Framework-specific dependencies (requirements.txt, package.json, etc.)
- ✅ Database service with persistent volumes
- ✅ Dotenv configuration with security practices
- ✅ **Hello World Console Command** - CLI validation tool
- ✅ **Hello World Web Endpoint** - HTTP server validation

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

2. **WebSearch Research:**
   - "Django 2024 development best practices setup Docker"
   - "Django recommended linting tools black flake8 mypy 2024"
   - "Django testing pytest vs unittest current trends"

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

2. **AI Synthesis:**
   ```text
   Detection Results → Stack Configuration
   • Framework: Django 4.2 (current version in project)
   • Database: PostgreSQL (from psycopg2 dependency)
   • Linters: black + flake8 + mypy + isort (research-based)
   • Testing: pytest + pytest-django (current best practice)
   • Directory: ./docker-dev/ (DOH default, unless specified)
   ```

3. **Dynamic Template Processing:**
   - Cherry-pick from `.claude/templates/init-dev/stacks/python/`
   - Adapt `.claude/templates/init-dev/services/postgres.yml`  
   - Customize `.claude/templates/init-dev/common/Makefile` with Django commands
   - Generate requirements.txt with researched optimal dependencies

4. **File Generation Process:**
   ```text
   AI Creates:
   • ./docker/docker-compose.yml → Django + PostgreSQL + Linter services
   • ./docker/docker-compose.env-docker → Project config with APP_CONTAINER variable
   • ./docker/Dockerfile → Python 3.12-slim with Django dependencies  
   • ./docker/Dockerfile.linter → Separate container with black/flake8/mypy/isort
   • ./docker/Makefile → Enhanced with Django-specific commands + hello-world target
   • ./requirements.txt → Django 5.0 + psycopg2 + pytest-django + linters
   • ./docker/traefik.yml-docker → HTTPS routing configuration
   • ./src/hello_world.py → Django Hello World view + management command
   • ./manage.py hello → Console Hello World command
   • ./INSTADEV.md → Quick start guide with test commands
   ```

5. **Stack Confirmation (Interactive Mode):**
   ```text
   🧠 Brainstormed Stack Configuration:
   
   📦 Technology: Python Django 5.0
   🗄️ Database: PostgreSQL 16
   🧪 Testing: pytest + pytest-django
   🎨 Linting: black + flake8 + mypy + isort
   📁 Directory: ./docker/
   🌐 Domain: https://app.{project}.localhost
   
   ✅ Proceed with this configuration? (y/N)
   ```

## Command Options

### Interactive Mode (Default)
```bash
/doh:init-dev "Python Django with PostgreSQL in ./docker directory"
# → Shows brainstormed configuration and waits for user confirmation
```

### Non-Interactive Mode (For Agents)
```bash
/doh:init-dev --non-interactive "Python Django with PostgreSQL in ./docker directory"
# → Proceeds immediately without confirmation prompts
# → Perfect for automated workflows and agent execution
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

## Why AI-Driven Approach?

**Not Scriptable Because:**
- Stack-specific best practices evolve rapidly
- Linting tools and versions change frequently  
- Framework-specific patterns vary significantly
- User preferences (directory structure, tooling) need flexibility
- Current industry trends require real-time research

**AI Advantages:**
- 🔍 Real-time web research for current best practices
- 🧠 Context-aware decision making based on stack analysis
- 🎯 Intelligent template cherry-picking and adaptation
- 💡 Dynamic version detection and compatibility checking
- 🛠️ Custom Makefile generation with stack-appropriate commands
- ✅ **Self-validation via Hello World testing** - never declares success until working

## Final Output & Testing

### 1. Hello World Implementation (AI Success Criteria)

**🎯 CRITICAL: Stack creation is NOT complete until both Hello Worlds work!**

**Console Command (CLI validation):**
```bash
# Stack-specific console hello world
make sh
# Then inside container:
npm run hello          # Node.js
python manage.py hello  # Django
php artisan hello       # Laravel  
python -c "print('Hello DOH!')"  # Generic Python
```

**Web Endpoint (HTTP validation):**
```bash
# Test web hello world endpoint
curl -k https://app.{project}.localhost/hello
# Expected response: {"message": "Hello from {Stack} on DOH!", "timestamp": "..."}
```

**AI Self-Validation Process:**
1. **Generate stack files**
2. **Run `make dev`** 
3. **Test console Hello World** → If fails: debug and fix
4. **Test web Hello World** → If fails: debug and fix  
5. **Only declare success when both Hello Worlds work**

### 2. Development Environment Testing

**Single Command Validation:**
```bash
make hello-world
# → Runs comprehensive stack validation:
#   ✅ Starts all services
#   ✅ Tests console command
#   ✅ Tests web endpoint
#   ✅ Validates database connectivity  
#   ✅ Checks linter container
#   ✅ Displays service URLs
```

### 3. Final Synthesis Report

**After successful creation, display:**
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

📝 **Next Steps:**
1. make dev          # Start development environment
2. make hello-world  # Validate everything works
3. make sh          # Enter main app container  
4. Start coding! 🚀

⚠️ **Note:** This stack was AI-validated - both Hello Worlds tested and working!
```

## Key Features

### Template-Based & Up-to-Date
- **Modular templates** from `.claude/templates/init-dev/`
- **Current versions** fetched from official APIs at runtime
- **Flexible composition** of services and stacks

### Linter Integration  
- **Separate containers** for linting tools per stack
- **Version isolation** - no conflicts with main application
- **Team standardization** - same tools for everyone
- **Profiles support** - start linters only when needed

### Multi-Project Support
- **Domain isolation** via `{service}.{project}.local`
- **SSL certificates** with mkcert wildcards
- **No port conflicts** - everything through Traefik
- **Project namespacing** in all configurations

### Developer Experience
- **One command setup** - `make dev-setup && make dev`
- **Comprehensive Makefile** with linting, database, and dev commands
- **Quick start guide** - INSTADEV.md with stack-specific examples
- **Template documentation** - clear extension points

This refactored approach makes the command much more maintainable and extensible while keeping the core logic focused on orchestration rather than template content.