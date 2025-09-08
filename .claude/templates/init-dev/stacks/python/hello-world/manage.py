#!/usr/bin/env python3

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

import os
import sys

def main():
    """Django-style management command"""
    if len(sys.argv) > 1 and sys.argv[1] == 'hello':
        # Hello command
        print(f"🎉 Hello World from {{PROJECT_NAME}} CLI")
        print(f"📁 Project: {os.getenv('PROJECT_NAME', '{{PROJECT_NAME}}')}")
        print(f"🕒 Timestamp: {datetime.now().isoformat()}")
        print(f"🌍 Environment: {os.getenv('DJANGO_ENV', 'development')}")
    elif len(sys.argv) > 1 and sys.argv[1] == 'runserver':
        # Simple server simulation
        host = sys.argv[2] if len(sys.argv) > 2 else '0.0.0.0:8000'
        print(f"✅ {{PROJECT_NAME}} server would run on {host}")
        print(f"🌐 Access at: https://app.{{PROJECT_NAME}}.localhost")
        print(f"🔧 Environment: {os.getenv('DJANGO_ENV', 'development')}")
    else:
        print("Available commands:")
        print("  hello      - Display hello world message")
        print("  runserver  - Show server info")

if __name__ == "__main__":
    from datetime import datetime
    main()