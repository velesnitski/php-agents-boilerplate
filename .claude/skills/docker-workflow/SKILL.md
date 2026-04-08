---
name: docker-workflow
description: Docker Compose infrastructure, deployment, and operations – all environments
user-invocable: false
---

# Docker & Deploy

## Stack
MySQL 8.0, Redis 7.4, Memcached 1.6, Nginx, PHP-FPM 8.2, PHP CLI 8.2, MinIO (S3), queue workers.

## Makefile Commands (preferred entry point)
```bash
make init              # full setup: clean, build, migrate, seed
make up / down         # start/stop containers
make restart           # down + up
make test              # run all tests
make check             # pint + phpstan + config check
make console           # bash into PHP CLI
make logs              # tail all container logs
make ps                # show running containers
make backup-mysql      # dump database
make restore-mysql     # restore from latest dump
make ssl               # generate local SSL certs
make build-release     # build + push Docker image
make deploy            # deploy to staging via SSH
make deploy-rebuild    # build + deploy combined
```

## Key Docker Patterns
- **CLI container** uses `profiles: [donotstart]` – only runs via `docker compose run --rm`
- **YAML anchors** (`&env-laravel` / `<<: *env-laravel`) for shared environment vars
- **wait-for-it.sh** ensures MySQL is ready before migrations
- **COMPOSE_PROJECT_NAME** in `.env` controls container naming – must match nginx template expectations
- **UID 1000:1000** ownership for storage/vendor/cache – `make check-dir-permissions` fixes this

## Deploy Flow
```
Pre-deploy: make test → make check → user approval → make build-release
Staging:    make deploy (SSH → pull → up → migrate)
Production: artisan down → pull → up → migrate → optimize → restart workers → artisan up
Rollback:   artisan down → switch image tag → pull → up → migrate:rollback → artisan up
```

## Post-Deploy Checks
1. Health endpoint: `curl -s http://HOST:PORT/`
2. Error logs: `docker compose logs --tail=50 app-php-fpm`
3. Queue processing: `docker compose logs app-worker-default`
4. Monitor 2–5 minutes for anomalies

## Common Issues
- **502 Bad Gateway** → PHP-FPM down or COMPOSE_PROJECT_NAME mismatch
- **Permission errors** → `make check-dir-permissions`
- **Stale config** → `php artisan config:clear` inside PHP-FPM container
- **Queue stuck** → `make restart-queue`, verify Redis is running
