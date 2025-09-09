# Framework Detection Process - DOH Kitchen

This document explains the systematic framework detection process used by the DOH Kitchen system to analyze project requests and existing codebases.

## Detection Process Overview

### 1. Natural Language Analysis
**Input Processing:** User request → Framework/technology extraction
- Parse natural language requests for technology mentions
- Extract explicit framework preferences (Django, Laravel, Express, etc.)
- Identify database preferences (PostgreSQL, MariaDB, MySQL, etc.)
- Detect frontend technology hints (Vue, React, Angular, etc.)

**Examples:**
```bash
"Django with PostgreSQL" → Framework: Django, Database: PostgreSQL
"Laravel blog with Vue.js" → Framework: Laravel, Database: MySQL (default), Frontend: Vue.js
"Node.js Express API" → Framework: Express, Database: none (inferred API-only)
"React app with backend" → Frontend: React, Framework: TBD (ambiguous backend)
```

### 2. File System Analysis (Detection Mode)
**File Pattern Recognition:** Scan existing project for framework indicators

#### Primary Detection Files
| Framework | Key Indicator Files | Confidence Level |
|-----------|-------------------|------------------|
| **Django** | `manage.py`, `settings.py`, `wsgi.py` | HIGH |
| **Laravel** | `artisan`, `composer.json` (laravel/framework) | HIGH |
| **Express** | `package.json` (express dependency) | HIGH |
| **Next.js** | `next.config.js`, `package.json` (next dependency) | HIGH |
| **Rails** | `Gemfile` (rails gem), `config/application.rb` | HIGH |
| **Symfony** | `composer.json` (symfony/* packages) | HIGH |
| **FastAPI** | `requirements.txt` (fastapi), `main.py` patterns | MEDIUM |
| **Flask** | `requirements.txt` (flask), `app.py` patterns | MEDIUM |

#### Secondary Detection Patterns
**Configuration Files:**
- `requirements.txt` → Python framework hints
- `composer.json` → PHP framework detection  
- `package.json` → Node.js framework analysis
- `Gemfile` → Ruby framework identification

**Directory Structure Analysis:**
```bash
# Django patterns
myapp/
├── manage.py           # Django CLI tool
├── myapp/
│   ├── settings.py     # Django settings
│   └── urls.py         # Django URL routing
└── apps/               # Django apps directory

# Laravel patterns  
project/
├── artisan            # Laravel CLI tool
├── app/
│   └── Http/          # Laravel HTTP layer
├── config/            # Laravel configuration
└── routes/            # Laravel routing

# Express patterns
project/
├── package.json       # Node.js dependencies
├── server.js          # Express server entry
└── routes/            # Express routing
```

### 3. Dependency Analysis
**Package File Parsing:** Extract framework information from dependency files

#### Python Projects (`requirements.txt`, `pyproject.toml`)
```python
# Django detection
Django>=4.0.0          → Django framework
django-rest-framework  → Django + API focus
celery                 → Worker queue detected

# Flask detection  
Flask>=2.0             → Flask framework
flask-sqlalchemy       → Flask + Database ORM
```

#### PHP Projects (`composer.json`)
```json
{
  "require": {
    "laravel/framework": "^10.0"     // Laravel framework
    "symfony/symfony": "^6.0"        // Symfony framework  
    "doctrine/orm": "^2.0"           // Database ORM
  }
}
```

#### Node.js Projects (`package.json`)
```json
{
  "dependencies": {
    "express": "^4.18.0",           // Express framework
    "next": "^13.0.0",              // Next.js framework
    "vue": "^3.0.0",                // Vue.js frontend
    "react": "^18.0.0"              // React frontend
  },
  "scripts": {
    "dev": "next dev"               // Next.js development
  }
}
```

### 4. Framework Resolution
**Resolution Strategy:** Handle multiple framework indicators

#### Resolution Rules
1. **Primary over Secondary**: `manage.py` beats generic `app.py`
2. **Explicit over Implicit**: User specification overrides detection
3. **Recent over Legacy**: Newer framework versions preferred
4. **Complete over Partial**: Full framework setup beats partial indicators

**Example Resolution:**
```bash
# Scenario: Both Flask and Django files detected
manage.py present        → Django (primary indicator)
app.py present          → Flask (secondary indicator)  
requirements.txt: Django → Django (dependency confirmation)
Resolution: Django framework selected
```

### 5. Database Detection
**Database Technology Identification:** Detect database preferences and configurations

#### Detection Methods
**Configuration Files:**
- `settings.py` (Django) → Database engine detection
- `.env` files → Database URL parsing
- `config/database.php` (Laravel) → Database driver
- Database client dependencies → Database type inference

**Dependency Analysis:**
```python
# Python database drivers
psycopg2-binary     → PostgreSQL
PyMySQL            → MySQL/MariaDB  
sqlite3            → SQLite (built-in)

# PHP database drivers  
ext-pdo_pgsql      → PostgreSQL
ext-pdo_mysql      → MySQL/MariaDB

# Node.js database clients
pg                 → PostgreSQL
mysql2             → MySQL/MariaDB
mongodb            → MongoDB
```

#### Default Database Pairing
**Framework → Database Statistical Pairing:**
- **Django** → PostgreSQL (community preference)
- **Laravel** → MySQL/MariaDB (framework default)
- **Express** → PostgreSQL (JavaScript ecosystem)
- **Rails** → PostgreSQL (Ruby ecosystem)
- **Symfony** → MySQL/MariaDB (PHP ecosystem)

### 6. Frontend Detection
**Frontend Technology Identification:** Detect frontend frameworks and build tools

#### Frontend Framework Detection
**Package.json Analysis:**
```json
{
  "dependencies": {
    "vue": "^3.4.0",              // Vue.js framework
    "react": "^18.2.0",           // React framework  
    "@angular/core": "^17.0.0"    // Angular framework
  },
  "devDependencies": {
    "vite": "^5.0.0",             // Vite build tool
    "webpack": "^5.0.0"           // Webpack build tool
  }
}
```

**Configuration File Detection:**
- `vite.config.js` → Vite build tool
- `webpack.config.js` → Webpack build tool
- `vue.config.js` → Vue CLI setup
- `next.config.js` → Next.js framework

#### Build Tool Detection
**Build Tool Priority:**
1. **Vite** (modern, fast)
2. **Webpack** (established, configurable)  
3. **Parcel** (zero-config)
4. **Rollup** (library-focused)

### 7. Version Detection
**Technology Version Identification:** Determine appropriate versions for detected technologies

#### Version Sources Priority
1. **Existing Project**: Preserve current versions from dependency files
2. **Docker Hub API**: Latest stable versions for new projects
3. **Framework Documentation**: Recommended versions
4. **Template Defaults**: Fallback versions in kitchen templates

#### Version Validation
**Compatibility Checking:**
- Framework minimum requirements
- Database client compatibility  
- Frontend build tool support
- Docker image availability

**Example Version Resolution:**
```bash
# Django project detection
requirements.txt: Django==4.1.0  → Preserve existing version
No requirements.txt found         → Use latest stable (5.0.x)
Docker Hub API: python:3.12-slim → Latest Python base image
```

### 8. Detection Output Format
**Structured Detection Results:** Consistent format for Kitchen processing

#### Detection Schema
```yaml
detection_results:
  framework:
    name: "django"
    version: "5.0.0"
    confidence: "HIGH"
    source: "manage.py + requirements.txt"
  
  database:
    type: "postgresql" 
    version: "16"
    confidence: "MEDIUM"
    source: "statistical_pairing"
  
  frontend:
    framework: "vue"
    version: "3.4.0"
    build_tool: "vite"
    confidence: "HIGH"
    source: "package.json"
  
  additional:
    workers: ["celery"]
    testing: ["pytest"]
    linting: ["ruff", "black"]
```

## Integration with Kitchen Process

### 1. Detection Phase Integration
**Kitchen Step Integration:**
- **Step 1**: Natural language analysis → Framework hints
- **Step 2**: File system scan (if --detect mode)
- **Step 3**: Dependency analysis → Version detection
- **Step 4**: Confidence scoring → Resolution strategy
- **Step 5**: Database/Frontend detection → Complete stack

### 2. User Interaction Patterns
**Interactive Mode:**
```bash
# Ambiguous detection → User confirmation required
Detection: "Django or Flask detected. Which do you prefer?"
User: "Django"
Resolution: Django framework selected
```

**Non-Interactive Mode:**
```bash
# Highest confidence wins
Django: HIGH confidence (manage.py + requirements.txt)
Flask: MEDIUM confidence (app.py only)  
Resolution: Django auto-selected
```

### 3. Error Handling
**Detection Failures:**
- **No Framework Detected**: Request user specification
- **Multiple High-Confidence**: Present options for user choice
- **Conflicting Dependencies**: Show conflict and request resolution
- **Unsupported Framework**: Provide closest supported alternative

### 4. Framework-Specific Processing
**Post-Detection Workflow:**
1. **Load Framework Templates**: Select appropriate kitchen templates
2. **Configure Build Strategy**: Set Docker multi-stage approach
3. **Generate Dependencies**: Create framework-specific dependency files
4. **Apply Framework Patterns**: Use framework-specific conventions

## Detection Quality Assurance

### 1. Detection Validation
**Validation Steps:**
- Verify detected framework can be installed
- Check database client compatibility
- Confirm frontend build tool support
- Validate Docker image availability

### 2. False Positive Prevention
**Common False Positives:**
- `app.py` (generic Python) vs Flask application
- `server.js` (generic Node.js) vs Express server
- PHP files without framework vs Laravel/Symfony

**Prevention Strategies:**
- Multi-file confirmation required
- Dependency cross-validation
- Directory structure verification
- Configuration file presence checking

### 3. Detection Improvements
**Continuous Learning:**
- Track detection accuracy across projects
- Update patterns based on framework evolution  
- Expand framework support based on user requests
- Refine confidence scoring algorithms

---

**The detection process ensures accurate framework identification while handling edge cases and user preferences gracefully.**