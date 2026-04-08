---
name: db-operations
description: Database operations reference – migrations, optimization, safety
---

# Database Operations

## Migration Safety
- Always `--pretend` first on production
- Always have a `down()` method
- Never `DROP` or `TRUNCATE` without backup
- Test migration on staging before prod
- For large tables: use batched operations, avoid locking

## Query Optimization Checklist
1. Run `EXPLAIN ANALYZE` on slow queries
2. Check for missing indexes (WHERE, JOIN, ORDER BY columns)
3. Check for N+1 – use `with()` eager loading
4. Avoid `SELECT *` – specify columns
5. Use `chunk()` or `cursor()` for large result sets
6. Consider composite indexes for multi-column WHERE

## Dangerous Operations (require user confirmation)
- DROP TABLE / DROP COLUMN
- TRUNCATE
- DELETE without WHERE
- ALTER TABLE on large tables (may lock)
- Any direct production DB modification

## Backup Commands
```bash
mysqldump -u USER -p DB > backup_$(date +%Y%m%d_%H%M%S).sql
pg_dump -U USER DB > backup_$(date +%Y%m%d_%H%M%S).sql
```

## Monitoring Queries
```sql
-- Active connections
SHOW PROCESSLIST;
-- Slow queries
SHOW VARIABLES LIKE 'slow_query%';
-- Table sizes
SELECT table_name, ROUND(data_length/1024/1024, 2) AS size_mb
FROM information_schema.tables WHERE table_schema = 'YOUR_DB';
```
