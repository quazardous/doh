# Traefik Kitchen Templates

Configuration templates for Traefik reverse proxy in DOH development stacks.

## Files

### etc/traefik.yaml-docker
Static configuration template for Traefik with:
- API dashboard enabled (insecure mode for development)
- Docker provider with project-specific container filtering
- File provider for dynamic SSL certificate configuration
- HTTP → HTTPS redirection
- Logging configuration
- Prometheus metrics

**Template Variables:**
- `{{PROJECT_NAME}}` → Project name for network and constraints
- `{{EXTERNAL_TRAEFIK_PORT}}` → Dashboard port (default: 8081)

### etc/dynamic.yaml
Dynamic configuration for SSL certificates:
- Certificate file paths with project-specific naming
- Support for both main domain and wildcard certificates

**Template Variables:**
- `{{PROJECT_NAME}}` → Project name for certificate naming
- `{{EXTERNAL_HTTPS_PORT}}` → HTTPS port (default: 4430)

## Generation Process

The `/doh:init-dev` command will:
1. Copy `etc/traefik.yaml-docker` → `./docker/traefik/traefik.yaml`
2. Replace template variables (`{{PROJECT_NAME}}`, etc.)
3. Adapt constraints for the specific project

**Note:** The generated `traefik.yaml` is gitignored to avoid configuration conflicts.

## Usage in docker-compose.yml

```yaml
traefik:
  image: traefik:v3.0
  ports:
    - "${EXTERNAL_HTTP_PORT:-8080}:80"
    - "${EXTERNAL_HTTPS_PORT:-4430}:443"
    - "${EXTERNAL_TRAEFIK_PORT:-8081}:8080"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
    - ./docker/traefik/traefik.yaml:/etc/traefik/traefik.yaml:ro
    - ./docker/traefik/dynamic.yaml:/etc/traefik/dynamic.yaml:ro
    - ./docker/traefik/certs:/etc/ssl/certs:ro
    - ./var/log/traefik:/var/log/traefik
```

## SSL Certificate Setup

The templates expect certificates to be generated with mkcert:

```bash
mkcert -install
mkcert -cert-file docker/traefik/certs/{{PROJECT_NAME}}.localhost.pem \
       -key-file docker/traefik/certs/{{PROJECT_NAME}}.localhost-key.pem \
       "{{PROJECT_NAME}}.localhost" "*.{{PROJECT_NAME}}.localhost"
```

## Service Configuration

Services should include Traefik labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.app-${PROJECT_NAME}.rule=Host(`app.${PROJECT_NAME}.localhost`)"
  - "traefik.http.routers.app-${PROJECT_NAME}.entrypoints=websecure"
  - "traefik.http.routers.app-${PROJECT_NAME}.tls=true"
  - "traefik.http.services.app-${PROJECT_NAME}.loadbalancer.server.port=8000"
  - "dev.project=${PROJECT_NAME}"
```

## Troubleshooting

- **Dashboard:** http://localhost:${EXTERNAL_TRAEFIK_PORT:-8081}
- **Logs:** `./var/log/traefik/traefik.log` and `./var/log/traefik/access.log`
- **Network filtering:** Only containers with `dev.project={{PROJECT_NAME}}` label are discovered
- **SSL issues:** Check certificate files in `./docker/traefik/certs/`