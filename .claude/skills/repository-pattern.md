---
name: repository-pattern
description: Repository pattern with contracts – data access layer conventions
---

# Repository Pattern

## Structure

```
app/Contracts/                     -- interfaces (what)
  UserRepositoryInterface.php
  NodeRepositoryInterface.php

app/Repositories/                  -- implementations (how)
  UserRepository.php
  NodeRepository.php

app/Providers/RepositoriesProvider.php  -- binding
```

## Interface Convention

```php
<?php

namespace App\Contracts;

use App\Models\User;
use Illuminate\Support\Collection;

interface UserRepositoryInterface
{
    public function findById(int $id): ?User;
    public function findByUuid(string $uuid): ?User;
    public function getActive(): Collection;
}
```

## Implementation Convention

```php
<?php

namespace App\Repositories;

use App\Contracts\UserRepositoryInterface;
use App\Models\User;
use Illuminate\Support\Collection;

class UserRepository implements UserRepositoryInterface
{
    public function findById(int $id): ?User
    {
        return User::find($id);
    }

    public function findByUuid(string $uuid): ?User
    {
        return User::where('uuid', $uuid)->first();
    }

    public function getActive(): Collection
    {
        return User::query()->active()->get();
    }
}
```

## Provider Binding

```php
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class RepositoriesProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(
            \App\Contracts\UserRepositoryInterface::class,
            \App\Repositories\UserRepository::class,
        );
    }
}
```

Register in `config/app.php` providers array or `bootstrap/providers.php` (Laravel 11).

## Rules
- Controllers and services depend on interfaces, never concrete repositories
- Repositories return Eloquent models or collections – no raw arrays
- Complex queries use Eloquent scopes on the model, called from the repository
- No business logic in repositories – only data access
- One repository per aggregate root (not per table)

## When NOT to use
- Simple CRUD with no reuse – direct Eloquent in service is fine
- One-off queries in commands or seeders
- Test-only data access
