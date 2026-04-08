---
name: server-infra
description: Docker Compose infrastructure – services, logs, health checks, Makefile workflow
user-invocable: false
---

# Server Infrastructure

## Docker Compose Stack
```
Services:
  app-mysql          MySQL 8.0          port 3360:3306
  app-redis          Redis 7.4 Alpine   default port
  app-memcache       Memcached 1.6      default port
  app-storage        MinIO (S3-compat)  console :80
  app-nginx          Nginx 1.25         port 8080:80
  app-php-fpm        PHP-FPM 8.2        port 9000 (internal)
  app-php-cli        PHP CLI 8.2        on-demand (profile: donotstart)
  app-schedule-work  Laravel Scheduler  php artisan schedule:work
  app-worker-default Queue Worker       php artisan queue:work --queue=default,emails --tries=3
```

## Service Management (via Makefile)
```bash
make up                    # pull images + start all services
make down                  # stop and remove containers
make restart               # down + up
make restart-queue         # restart only queue workers and scheduler
make ps                    # show running containers with ports and status
make images                # show pulled images
make console               # bash into PHP CLI container
make console-fpm           # bash into PHP-FPM container
make logs                  # tail -f all container logs
```

## Log Locations
```
storage/logs/laravel.log          -- application log (inside container)
docker compose logs app-nginx     -- nginx access/error logs
docker compose logs app-php-fpm   -- PHP-FPM logs
docker compose logs app-mysql     -- MySQL logs
```

## Health Checks
```bash
# HTTP health
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/

# MySQL (built-in Docker healthcheck)
docker compose exec app-mysql mysql -h 127.0.0.1 --password=$DB_ROOT_PWD -e "USE $DB_DATABASE;"

# Redis
docker compose exec app-redis redis-cli ping

# PHP-FPM ping (if configured)
curl http://localhost:8080/fpm-ping

# Queue status
docker compose exec app-php-fpm php artisan queue:monitor
```

## Database Operations
```bash
make init-db               # start MySQL, wait for ready, migrate, seed
make backup-mysql          # dump database to storage/db/
make restore-mysql         # restore from latest dump
make clean-db              # remove MySQL data volume (destructive!)
make wait-mysql            # wait for MySQL to accept connections
```

## SSL / Certificates
```bash
make ssl                   # generate self-signed SSL certs for local dev
```

## Resource Monitoring
```bash
docker stats               # CPU/memory per container
docker compose exec app-php-fpm df -h    # disk usage
docker system df           # Docker disk usage
```

## Common Issues
- **502 Bad Gateway** → PHP-FPM down or nginx can't resolve PHP-FPM hostname. Check `COMPOSE_PROJECT_NAME` matches nginx template expectations
- **MySQL connection refused** → container still starting. Run `make wait-mysql` or check healthcheck
- **Permission errors** → run `make check-dir-permissions` to fix storage/vendor/cache ownership
- **Stale config** → run `php artisan config:clear` inside PHP-FPM container after .env changes
- **Queue not processing** → check `make restart-queue`, verify Redis is running
- **Disk full** → check `make clean-logs`, `make clean-s3`, Docker volumes
