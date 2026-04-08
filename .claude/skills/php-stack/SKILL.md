---
name: php-stack
description: PHP 8.2 / Laravel 11 stack reference – project structure, patterns, tooling
user-invocable: false
---

# PHP Stack Reference

## Framework
PHP 8.2+, Laravel 11.x, Eloquent ORM, Artisan CLI, Predis for Redis.

## Project Structure
```
app/
  Contracts/             -- repository interfaces
  Enums/                 -- PHP 8.1+ backed enums
  Http/Controllers/      -- thin, delegates to services
  Http/Requests/         -- form request validation
  Http/Resources/        -- API response transformation
  Models/                -- Eloquent models
  Providers/             -- service providers (app, repositories)
  Repositories/          -- data access (implements Contracts)
  Services/              -- stateless business logic
  Traits/{Enums,Models}/ -- shared behavior
  Jobs/, Events/, Listeners/
config/                  -- env-backed configuration
database/{factories,migrations,seeders}/
docs/adr/                -- architecture decision records
routes/{web,api}.php
tests/{Feature,Unit}/
```

## Key Artisan Commands
```bash
php artisan test --filter=Name   # run specific test
php artisan migrate --pretend    # dry-run migration
php artisan make:model X -mfc   # model + migration + factory + controller
php artisan route:list           # show routes
php artisan tinker               # REPL
```

For Make commands see `docker-workflow` skill.

## Patterns
- **Repository pattern** – Contracts + Repositories, bound in `RepositoriesProvider`
- **Service classes** – stateless, injected via constructor DI
- **Thin controllers** – delegate to services, no business logic
- **FormRequest validation** – never validate in controllers
- **PHP 8.1+ Enums** – backed enums with traits
- **Config over env** – use `config()` not `env()` in app code
- **Queue heavy work** – email, API calls, reports

## Code Quality
Pint (PSR-12), Larastan/PHPStan, PHPUnit 11, Allure reporting. Check `composer.json` for versions.
