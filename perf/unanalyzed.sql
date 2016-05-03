SELECT 
  --nspname,
  relname,
  last_vacuum,
  last_analyze,
  age(relfrozenxid)
FROM
(
SELECT
  c.oid,
  N.nspname,
  C.relname,
  date_trunc('day',greatest(pg_stat_get_last_vacuum_time(C.oid),pg_stat_get_last_autovacuum_time(C.oid)))::date AS last_vacuum,
  date_trunc('day',greatest(pg_stat_get_last_analyze_time(C.oid),pg_stat_get_last_analyze_time(C.oid)))::date AS last_analyze,
  C.relfrozenxid
FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE
    C.relkind IN ('r', 't') AND
    N.nspname NOT IN ('pg_catalog', 'information_schema') AND
    N.nspname !~ '^pg_toast'
) AS av
WHERE
  (last_analyze IS NULL) OR
  (last_analyze < (now() - '1 day'::interval))
ORDER BY last_analyze NULLS FIRST
--LIMIT 24
;


