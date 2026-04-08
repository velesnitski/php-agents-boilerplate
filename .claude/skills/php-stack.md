---
name: php-stack
description: PHP 8.2 / Laravel 11 stack reference – project structure, patterns, tooling
---

# PHP Stack Reference

## Framework
- PHP 8.2+
- Laravel 11.x
- Eloquent ORM for database access
- Blade templates for server-rendered views (if any)
- Artisan CLI for scaffolding and maintenance
- Predis for Redis communication

## Project Structure
```
app/
  Contracts/               -- repository interfaces
  Enums/                   -- PHP 8.1+ backed enums
  Http/Controllers/        -- request handling (thin, delegates to services)
  Http/Requests/           -- form request validation
  Http/Resources/          -- API response transformation
  Models/                  -- Eloquent models
  Providers/               -- service providers (app, repositories)
  Repositories/            -- data access layer (implements Contracts)
  Services/                -- business logic (stateless, injectable)
  Traits/
    Enums/                 -- shared enum behavior
    Models/                -- shared model traits (e.g. UUID generation)
  Jobs/                    -- async queue jobs
  Events/                  -- event classes
  Listeners/               -- event handlers
config/                    -- env-backed configuration
database/
  factories/               -- model factories for testing
  migrations/              -- schema changes (always with down())
  seeders/                 -- seed data
docker/                    -- Docker configs per environment
  common/                  -- shared configs (nginx, php, redis, scripts)
  development/             -- dev-specific Dockerfiles and configs
  staging/                 -- staging Dockerfiles, compose, nginx
docs/
  adr/                     -- architecture decision records
routes/
  web.php                  -- web routes
  api.php                  -- API routes (if present)
tests/
  Feature/                 -- feature/integration tests
    Controllers/           -- controller endpoint tests
    Services/              -- service integration tests
    Http/Requests/         -- form request validation tests
  Unit/                    -- unit tests
    Services/              -- service unit tests
    Console/               -- command tests
    Requests/              -- request unit tests
```

## Key Commands
```bash
# Development (via Makefile – preferred)
make up                             # start Docker containers
make down                           # stop containers
make restart                        # restart containers
make init                           # full project init (clean, build, migrate, seed)
make test                           # run all tests
make test-optimize                  # restart + optimize + test
make check                          # composer check + pint + config check
make console                        # bash into PHP CLI container
make logs                           # tail all container logs
make ps                             # show running containers
make backup-mysql                   # backup database
make restore-mysql                  # restore from latest dump

# Artisan (inside container or via make)
php artisan test                    # run tests
php artisan test --filter=ClassName # run specific test
php artisan migrate                 # run migrations
php artisan migrate:rollback        # undo last batch
php artisan migrate --pretend       # dry-run migrations
php artisan make:model Name -mfc    # model + migration + factory + controller
php artisan route:list              # show all routes
php artisan tinker                  # REPL
php artisan optimize                # cache config, routes, views
php artisan config:clear            # clear cached config

# Code Quality
./vendor/bin/pint                   # fix code style (Laravel Pint / PSR-12)
./vendor/bin/pint --test            # check code style without fixing
./vendor/bin/phpstan analyse        # static analysis (Larastan)
./vendor/bin/phpunit                # run tests directly
```

## Patterns
- **Repository pattern** – data access via Contracts (interfaces) + Repository implementations, bound in `RepositoriesProvider`
- **Service classes** – stateless business logic, injected via constructor DI
- **Thin controllers** – controllers delegate to services, never contain business logic
- **FormRequest validation** – validate in dedicated request classes, not controllers
- **PHP 8.1+ Enums** – use backed enums with traits for extensibility
- **Model traits** – shared behavior (UUID generation, etc.) via traits in `app/Traits/Models/`
- **Config over env** – use `config()` not `env()` in application code
- **Queue heavy work** – email, API calls, reports go to queue workers

## Dev Dependencies
- **PHPUnit 11** – testing framework
- **Larastan / PHPStan** – static analysis
- **Laravel Pint** – code style (PSR-12)
- **PHP_CodeSniffer** – additional code standard checks
- **Laravel Pail** – real-time log viewer
- **Allure PHPUnit** – test reporting
- **Mockery** – test mocking
- **Faker** – test data generation
