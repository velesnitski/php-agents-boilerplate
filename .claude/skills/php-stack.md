---
name: php-stack
description: PHP/Laravel stack reference for backend development
---

# PHP Stack Reference

## Framework
- Laravel (check composer.json for exact version)
- Eloquent ORM for database access
- Blade templates for server-rendered views (if any)
- Artisan CLI for scaffolding and maintenance

## Project Structure
```
app/
  Http/Controllers/    -- request handling
  Http/Requests/       -- form request validation
  Http/Resources/      -- API response transformation
  Models/              -- Eloquent models
  Services/            -- business logic
  Jobs/                -- async queue jobs
  Events/              -- event classes
  Listeners/           -- event handlers
config/                -- env-backed configuration
database/migrations/   -- schema changes
routes/api.php         -- API routes
tests/Feature/         -- feature/integration tests
tests/Unit/            -- unit tests
```

## Key Commands
```bash
php artisan test                    # run tests
php artisan migrate                 # run migrations
php artisan migrate:rollback        # undo last batch
php artisan make:model Name -mfc    # model + migration + factory + controller
php artisan route:list              # show all routes
php artisan tinker                  # REPL
composer install --no-dev           # production install
```

## Patterns
- Fat models are anti-pattern – use Service classes
- Validate in FormRequest, not controller
- Transform responses via API Resources
- Use config() not env() in application code
- Queue heavy work (email, API calls, reports)
