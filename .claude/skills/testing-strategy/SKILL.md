---
name: testing-strategy
description: PHPUnit testing conventions – feature vs unit, structure, tools, coverage
user-invocable: false
---

# Testing Strategy

## Test Structure
```
tests/
  TestCase.php                          -- base test class
  CreatesApplication.php                -- app bootstrap trait
  Feature/
    Controllers/                        -- endpoint tests (HTTP layer)
      Api/                              -- public API controllers
      Subscription/                     -- subscription controllers
    Http/Requests/                      -- form request validation tests
    Services/                           -- service integration tests
  Unit/
    Services/                           -- service unit tests (mocked deps)
    Console/Commands/                   -- artisan command tests
    Requests/                           -- request rule tests
```

## Feature vs Unit

**Feature tests** – test through HTTP, hit real database:
```php
class PageControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_show_returns_200_for_valid_token(): void
    {
        $order = Order::factory()->create();

        $response = $this->get("/{$order->uuid}");

        $response->assertStatus(200);
    }
}
```

**Unit tests** – test single class, mock dependencies:
```php
class TokenGeneratorTest extends TestCase
{
    public function test_password_to_uuid_returns_valid_format(): void
    {
        $uuid = TokenGenerator::passwordToUuid('test-password');

        $this->assertMatchesRegularExpression(
            '/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/',
            $uuid,
        );
    }
}
```

## Running Tests
```bash
# Via Makefile (recommended – runs inside Docker)
make test                              # all tests
make test-optimize                     # restart + optimize + test

# Via Artisan (inside container)
php artisan test                       # all tests
php artisan test --filter=ClassName    # specific test class
php artisan test --filter=test_method  # specific test method

# Via PHPUnit directly
./vendor/bin/phpunit                   # all tests
./vendor/bin/phpunit --coverage-html storage/coverage  # with coverage

# Coverage (requires Xdebug)
make laravel-test-coverage             # HTML coverage report in storage/coverage/
```

## Conventions
- Test class name mirrors source: `App\Services\Foo` → `Tests\Unit\Services\FooTest`
- Test methods use `test_` prefix with snake_case description
- One assertion concept per test – multiple `assert*` calls are fine if testing one behavior
- Use factories for test data, not manual model creation
- Feature tests use `RefreshDatabase` trait
- Never test framework internals (Eloquent, routing) – test your logic

## Tools
- **PHPUnit 11** – test runner
- **Mockery** – mocking (prefer over PHPUnit mocks for readability)
- **Faker** – realistic test data via factories
- **Allure PHPUnit** – test reporting with screenshots and steps
- **Laravel Pail** – watch logs during test runs

## What to Test
- Every public API endpoint (happy path + error cases)
- Service methods with business logic
- Form request validation rules
- Enum behavior and edge cases
- Complex Eloquent scopes

## What NOT to Test
- Eloquent relationships (framework handles this)
- Simple getters/setters
- Config files
- Migration syntax (migration tests are for data integrity)
