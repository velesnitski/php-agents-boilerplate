---
name: docker-workflow
description: Docker Compose multi-environment setup – dev, staging, production patterns
---

# Docker Workflow

## Multi-Environment Setup
```
docker/
  common/                  -- shared across all environments
    nginx/
      conf.d/              -- base nginx config
      templates/           -- nginx vhost templates (env var substitution)
    php/
      conf.d/              -- shared PHP ini settings (security.ini)
      php-fpm.d/           -- FPM pool configs (ping.conf)
    redis/                 -- Redis config and Dockerfile
    mysql-backup/          -- backup.sh, restore.sh scripts
    ssl/                   -- SSL certificate generation
    wait-for-it.sh         -- service readiness script
  development/
    nginx/Dockerfile       -- dev nginx with SSL
    php-cli/Dockerfile     -- dev CLI with Xdebug
    php-fpm/Dockerfile     -- dev FPM with Xdebug
    php/conf.d/xdebug.ini  -- Xdebug config
  staging/
    docker-compose.yml     -- staging compose (image-based, not build)
    nginx/                 -- staging nginx config
    php-fpm/               -- staging FPM (no Xdebug)
  composer/                -- Composer cache and auth
```

## Docker Compose Services Pattern

```yaml
services:
  # Database – persistent volume
  app-mysql:
    image: mysql:8.0
    volumes: ["./storage/mysql.data:/var/lib/mysql"]
    healthcheck:
      test: ["CMD", "mysql", "-h", "127.0.0.1", "--password=${DB_ROOT_PWD}", "-e", "USE ${DB_DATABASE};"]

  # Cache layers
  app-redis:
    image: redis:7.4-alpine
    volumes: ["./storage/redis:/data"]

  app-memcache:
    image: memcached:1.6

  # Object storage (S3-compatible)
  app-storage:
    image: minio/minio

  # Web server – depends on PHP-FPM
  app-nginx:
    depends_on: [app-php-fpm]
    environment:
      PHN_WWW_PHP_FPM_HOST: "app-php-fpm"
      PHN_WWW_PHP_FPM_PORT: 9000
    volumes: ["./:/app"]
    ports: ["8080:80"]

  # PHP-FPM – application runtime
  app-php-fpm:
    depends_on: [app-redis, app-mysql, app-memcache]
    build:
      dockerfile: docker/php-fpm/Dockerfile
    volumes: ["./:/app"]

  # PHP CLI – on-demand (composer, artisan, tests)
  app-php-cli:
    profiles: [donotstart]   # only runs via `docker compose run`
    build:
      dockerfile: docker/php-cli/Dockerfile
    user: "1000:1000"

  # Background workers
  app-schedule-work:
    command: ["php", "artisan", "schedule:work"]

  app-worker-default:
    command: ["php", "artisan", "queue:work", "--queue=default,emails", "--tries=3"]
```

## Key Patterns

### YAML anchors for shared env
```yaml
environment: &env-laravel
  PHP_IDE_CONFIG: "serverName=Docker"

# Reuse:
environment:
  <<: *env-laravel
  EXTRA_VAR: "value"
```

### CLI container with `profiles: [donotstart]`
The CLI container never auto-starts. Use `docker compose run --rm app-php-cli <command>` for one-off tasks (composer, artisan, tests).

### wait-for-it.sh
Ensure MySQL is ready before running migrations:
```bash
docker compose run -u 0 --rm app-php-cli /app/docker/common/wait-for-it.sh app-mysql:3306 -t 120
```

### COMPOSE_PROJECT_NAME
Set in `.env` to control container/network naming. Critical when nginx templates resolve PHP-FPM hostname from environment variables.

## Staging Deploy Pattern
Staging uses **pre-built images** (not `build:`):
1. Build image locally: `docker buildx build --push`
2. SSH to staging host
3. Copy `docker-compose.yml` with `sed` variable substitution
4. `docker compose pull && docker compose up -d`
5. Run migrations via `docker compose run`

## Permissions
Storage, vendor, cache directories need UID 1000:1000 ownership. The Makefile handles this via `make check-dir-permissions` using an Alpine container.
