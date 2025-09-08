FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000

# Create user matching host UID/GID
RUN groupadd -g ${GID} appuser \
    && useradd -u ${UID} -g ${GID} -m -s /bin/bash appuser

WORKDIR /app

# Install Python dependencies
COPY --chown=${UID}:${GID} requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY --chown=${UID}:${GID} . .

# Switch to non-root user
USER appuser

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]