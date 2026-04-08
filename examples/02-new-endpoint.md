# New Endpoint (Complex Task)

## User input
```
> Add GET /api/users/{id}/activity – returns last 30 days of activity, paginated
```

## Router classification
```
Task type: Complex (new feature, schema change needed)
Chain: DBA → Backend Dev → QA → User review → Ops
```

## DBA output
```
## Schema Changes
- Table: user_activities (new)
- Migration: 2026_04_08_create_user_activities_table.php

## Risk Assessment
- Data loss risk: none (new table)
- Downtime required: no
- Rollback: drop table

## Prerequisites
- Backup needed: no
- Maintenance window: no
```

## Backend Dev output
```
## Changes
- app/Models/UserActivity.php: new model
- app/Http/Controllers/UserActivityController.php: index() with pagination
- app/Http/Requests/UserActivityIndexRequest.php: validates user_id, date range
- app/Http/Resources/UserActivityResource.php: response transformation
- routes/api.php: added route

## Tests
- Ran: 43 passed, 0 failed
- New: UserActivityControllerTest (3 tests)

## Notes
- Migration needed: yes (created by DBA)
```

## QA output
```
## Test Results
- Suite: 46 passed, 0 failed

## Verification
- [x] GET /api/users/1/activity returns paginated results
- [x] Only last 30 days returned
- [x] Invalid user_id returns 404
- [x] Pagination params work (page, per_page)

## Verdict: PASS
```

## User review
```
> Looks good, deploy to staging
```

## Ops output
```
## Action
- Built image: 0.0.10
- Deployed to staging
- Migration ran successfully

## Verification
- Health check: pass
- Logs: clean
- Endpoint responds: 200 OK
```
