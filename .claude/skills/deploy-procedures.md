---
name: deploy-procedures
description: Docker-based deployment workflow with Makefile, staging via SSH, rollback
---

# Deploy Procedures

## Environments
- **Development** – local Docker Compose (`make up`)
- **Staging** – remote Docker Compose via SSH (`make deploy`)
- **Production** – Docker Compose with production override

## Pre-Deploy Checklist
- [ ] All tests pass (`make test`)
- [ ] Code style clean (`make check-pint`)
- [ ] Static analysis passes (`./vendor/bin/phpstan analyse`)
- [ ] Migrations reviewed by DBA (if any)
- [ ] User approved the changes
- [ ] Docker image built and pushed (`make build-release`)

## Local Development
```bash
make init          # full setup: clean, composer install, key gen, SSL, migrate, seed
make up            # start containers
make test          # run tests
make check         # pint + phpstan + config check
```

## Staging Deploy (via Makefile)
```bash
# 1. Build and push Docker image
make build-release

# 2. Deploy to staging server
make deploy
# This runs:
#   - SSH to staging host
#   - docker compose down
#   - copy docker-compose.yml with version substitution
#   - copy .env with project name substitution
#   - copy nginx config
#   - docker compose pull
#   - composer check
#   - docker compose up -d
#   - php artisan migrate

# 3. Combined build + deploy
make deploy-rebuild
```

## Production Deploy
```bash
# 1. Maintenance mode
docker compose exec app-php-fpm php artisan down --retry=60

# 2. Pull latest images
docker compose pull

# 3. Recreate containers
docker compose up -d

# 4. Run migrations
docker compose exec app-php-fpm php artisan migrate --force

# 5. Optimize
docker compose exec app-php-fpm php artisan optimize

# 6. Restart workers
docker compose restart app-schedule-work app-worker-default

# 7. Go live
docker compose exec app-php-fpm php artisan up
```

## Post-Deploy Verification
1. Hit health endpoint: `curl -s http://HOST:PORT/`
2. Check error log: `docker compose logs --tail=50 app-php-fpm`
3. Monitor response times for 2–5 minutes
4. Verify key user flows work
5. Check queue is processing: `docker compose logs app-worker-default`

## Rollback
```bash
# 1. Maintenance mode
docker compose exec app-php-fpm php artisan down

# 2. Switch to previous image tag
# Edit docker-compose.yml or set IMAGE_TAG=previous_version

# 3. Pull and restart
docker compose pull
docker compose up -d

# 4. Rollback migrations if needed
docker compose exec app-php-fpm php artisan migrate:rollback

# 5. Optimize and go live
docker compose exec app-php-fpm php artisan optimize
docker compose exec app-php-fpm php artisan up
```

## Database Backup/Restore
```bash
make backup-mysql      # create timestamped dump
make restore-mysql     # restore from latest dump
```

Always backup before migrations on staging/production.
