#!/usr/bin/env python3

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

import os
from datetime import datetime

def main():
    """Django-style Hello World application"""
    print(f"🎉 Hello World from {{PROJECT_NAME}} Python App")
    print(f"📁 Project: {os.getenv('PROJECT_NAME', '{{PROJECT_NAME}}')}")
    print(f"🕒 Timestamp: {datetime.now().isoformat()}")
    print(f"🐍 Python version: {os.sys.version}")
    print(f"🌍 Environment: {os.getenv('DJANGO_ENV', 'development')}")
    
    # Show environment variables loaded from .env
    env_vars = [
        'PROJECT_NAME',
        'DJANGO_ENV', 
        'DATABASE_URL',
        'SECRET_KEY'
    ]
    
    print("\n🔧 Environment variables:")
    for var in env_vars:
        value = os.getenv(var, 'Not set')
        # Mask sensitive values
        if 'SECRET' in var or 'PASSWORD' in var or 'KEY' in var:
            value = '***' if value != 'Not set' else 'Not set'
        print(f"  • {var}: {value}")

if __name__ == "__main__":
    main()