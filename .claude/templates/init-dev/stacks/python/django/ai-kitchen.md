# AI-Kitchen Instructions for Django Stack

## Django Project Initialization

**@AI-Kitchen: GENERATE - Django project creation workflow**

### Step 1: Install Django
```bash
# Inside the container or virtual environment
pip install django
```

### Step 2: Create Django Project
```bash
# Initialize new Django project with proper name
django-admin startproject {{PROJECT_NAME}} .
```

**Important Notes:**
- The `.` at the end creates the project in the current directory (not a subdirectory)
- Use `{{PROJECT_NAME}}` placeholder for project name consistency
- This creates the standard Django structure: `manage.py`, `{{PROJECT_NAME}}/settings.py`, etc.

### Step 3: Database Configuration
Django projects need database configuration in `{{PROJECT_NAME}}/settings.py`:

```python
# For MariaDB/MySQL
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': '{{PROJECT_NAME}}',
        'USER': '{{PROJECT_NAME}}',
        'PASSWORD': '{{PROJECT_NAME}}',
        'HOST': 'mariadb',  # Docker service name
        'PORT': '3306',
    }
}
```

### Step 4: Initial Migration
```bash
# Create initial database tables
python manage.py migrate
```

### Step 5: Development Server
```bash
# Start Django development server
python manage.py runserver 0.0.0.0:8000
```

## @AI-Kitchen: Framework-Specific Requirements

- **Dependencies**: `django`, `mysqlclient` (for MariaDB/MySQL)
- **Port**: 8000 (standard Django development server)
- **Process**: Use `python manage.py runserver 0.0.0.0:8000` in supervisord or as main process
- **Static files**: Handle with `python manage.py collectstatic` for production