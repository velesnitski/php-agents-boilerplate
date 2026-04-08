---
name: server-infra
description: Server infrastructure reference – services, logs, health checks
---

# Server Infrastructure

## Service Management
```bash
systemctl status nginx php-fpm redis mysql    # check status
systemctl restart php-fpm                      # restart PHP
supervisorctl status                           # queue workers
```

## Log Locations
```
storage/logs/laravel.log       -- application log
/var/log/nginx/error.log       -- web server errors
/var/log/nginx/access.log      -- request log
/var/log/mysql/slow.log        -- slow queries
/var/log/syslog                -- system log
```

## Health Checks
- HTTP: `curl -s -o /dev/null -w "%{http_code}" https://DOMAIN/api/health`
- PHP-FPM: `systemctl is-active php-fpm`
- Queue: `php artisan queue:monitor` or check supervisor
- Redis: `redis-cli ping`
- DB: `php artisan db:monitor`

## Resource Monitoring
```bash
htop                           # CPU/memory
df -h                          # disk usage
ss -tlnp                       # open ports
free -h                        # memory
```

## Common Issues
- 502 Bad Gateway → PHP-FPM down or socket mismatch
- High memory → check queue workers, long-running jobs
- Disk full → check logs, storage/framework/cache, /tmp
- Slow responses → check slow query log, PHP-FPM pool size
