---
name: deploy-procedures
description: Deployment workflow and rollback procedures
---

# Deploy Procedures

## Pre-Deploy Checklist
- [ ] All tests pass
- [ ] Migrations reviewed by DBA (if any)
- [ ] User approved the changes
- [ ] Current state tagged/noted for rollback

## Deploy Steps
```bash
# 1. Maintenance mode
php artisan down --retry=60

# 2. Pull and install
git pull origin main
composer install --no-dev --optimize-autoloader

# 3. Migrations (if any)
php artisan migrate --force

# 4. Cache refresh
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 5. Restart workers
supervisorctl restart all
# or: php artisan queue:restart

# 6. Go live
php artisan up
```

## Post-Deploy Verification
1. Hit health endpoint
2. Check error log for new errors
3. Monitor response times for 2–5 minutes
4. Verify key user flows work

## Rollback
```bash
php artisan down
git checkout PREVIOUS_TAG
composer install --no-dev --optimize-autoloader
php artisan migrate:rollback    # if migration was run
php artisan config:cache
php artisan route:cache
supervisorctl restart all
php artisan up
```

## Zero-Downtime (if available)
- Use Envoy, Deployer, or similar
- Symlink-based releases with shared storage
- Run migrations before switching symlink (if backward-compatible)
