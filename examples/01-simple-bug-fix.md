# Simple Bug Fix

## User input
```
> The /api/orders endpoint returns 500 when page parameter is 0
```

## Router classification
```
Task type: Simple (bug fix)
Chain: Backend Dev → QA → User review
```

## Backend Dev output
```
## Changes
- app/Http/Requests/OrderIndexRequest.php: added `min:1` rule for `page` parameter
- app/Http/Controllers/OrderController.php: no changes needed (validation handles it)

## Tests
- Ran: 42 passed, 0 failed
- New: OrderIndexRequestTest::test_page_zero_returns_422

## Notes
- Migration needed: no
- Breaking changes: none (invalid input now returns 422 instead of 500)
```

## QA output
```
## Test Results
- Suite: 43 passed, 0 failed, 0 skipped

## Verification
- [x] page=0 returns 422 with validation message
- [x] page=1 works as before
- [x] page=-1 returns 422
- [x] No regression in /api/orders

## Verdict: PASS
```
