# Django Satellite Tools Matrix
# Updated for DOH init-dev Django kitchen

## Framework-Specific Tool Requirements (Django Stack)

**🔍 DISCOVERY VIA WEBSEARCH:**
AI uses WebSearch to discover satellite tools specific to Django technology:
- `"Django development requirements tools 2024"` → Discovers pip, python3-dev, libpq-dev, mysqlclient
- `"Django production deployment tools 2024"` → Discovers gunicorn, whitenoise, static file handling
- `"Django testing tools pytest vs unittest 2024"` → Discovers pytest-django, factory-boy, coverage

**📊 DJANGO TOOLS MATRIX:**

| Component | Development Tools | Build Tools | Database Libs | System Tools |
|-----------|------------------|-------------|---------------|--------------|
| **Django Core** | `django`, `django-extensions` | `pip`, `python3-dev` | `psycopg2`, `mysqlclient` | `python3`, `git` |
| **Django Testing** | `pytest-django`, `factory-boy` | `coverage`, `pytest-cov` | Test database drivers | `build-essential` |
| **Django Frontend** | `django-vite`, `django-webpack-loader` | `node`, `npm` | N/A | `nodejs` |
| **Django Production** | `gunicorn`, `whitenoise` | `wheel`, `setuptools` | Production DB drivers | `supervisor` |
| **Django API** | `djangorestframework`, `django-cors-headers` | API documentation tools | N/A | N/A |
| **Django Background** | `celery`, `django-rq` | Task queue brokers | `redis`, `rabbitmq` | Queue system tools |

**🚨 DJANGO-SPECIFIC RULES:**

1. **Project Initialization:**
   ```bash
   # CORRECT Django pattern
   pip install django
   django-admin startproject myproject .
   python manage.py migrate
   
   # NOT generic Python pattern
   mkdir myproject && cd myproject
   ```

2. **Database Integration:**
   ```bash
   # Django ORM-first approach
   python manage.py makemigrations
   python manage.py migrate
   
   # NOT raw SQL migrations
   ```

3. **Static Files Management:**
   ```bash
   # Django collectstatic pattern
   python manage.py collectstatic --noinput
   
   # NOT manual file copying
   ```

4. **Testing Pattern:**
   ```bash
   # Django test discovery
   python manage.py test                    # Native Django tests
   pytest                                   # pytest-django integration
   
   # NOT generic Python testing
   ```

**🔧 DJANGO MAKEFILE COMMANDS:**

| Command Category | Make Target | Real Django Command | Purpose |
|------------------|-------------|---------------------|---------|
| **Initialization** | `django-init` | `django-admin startproject` | Create Django project structure |
| **Database** | `django-migrate` | `python manage.py migrate` | Apply database migrations |
| **Database** | `django-makemigrations` | `python manage.py makemigrations` | Create new migrations |
| **Admin** | `django-createsuperuser` | `python manage.py createsuperuser` | Create admin user |
| **Development** | `django-shell` | `python manage.py shell` | Interactive Django shell |
| **Static Files** | `django-collectstatic` | `python manage.py collectstatic` | Collect static files |
| **Testing** | `test` | `python manage.py test` | Run Django native tests |
| **Testing** | `test-pytest` | `pytest` | Run pytest with django plugin |

**🎯 DJANGO KITCHEN PRIORITY:**

1. **Always use `django-admin startproject`** - NOT manual directory creation
2. **Always use `python manage.py` commands** - NOT generic Python scripts  
3. **Always include Django-specific dependencies** - `django-extensions`, `django-debug-toolbar`
4. **Always configure Django settings properly** - Database, static files, templates
5. **Always include Django testing setup** - `pytest-django` or native Django tests

**💡 MAKEFILE VARIABLE PATTERN:**

```makefile
# Django-specific command variables
DJANGO_MANAGE = $(RUN_APP) python manage.py
DJANGO_STARTPROJECT = $(RUN_APP) django-admin startproject {{PROJECT_NAME}} .
DJANGO_SHELL = $(DJANGO_MANAGE) shell
DJANGO_MIGRATE = $(DJANGO_MANAGE) migrate
DJANGO_TEST = $(DJANGO_MANAGE) test

# Usage in targets
django-init: ## Initialize Django project
	@$(PIP_INSTALL)
	@$(DJANGO_STARTPROJECT) 
	@$(DJANGO_MIGRATE)
```

This ensures Django kitchen always uses proper Django tooling patterns, not generic Python patterns.