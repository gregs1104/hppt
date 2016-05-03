--CREATE VIEW vacuum_stats AS
SELECT 
  --nspname,
  relname,n_dead_tup::numeric,
  reltuples::numeric,
  pg_size_pretty(pg_relation_size(oid)) AS table_sz,
  pg_size_pretty(pg_total_relation_size(oid)) AS total_sz,
  last_vacuum,
  last_analyze,
  --n_dead_tup > av_threshold AS "av_needed",
  CASE WHEN reltuples > 0
    THEN round(100.0 * n_dead_tup / (reltuples))
    ELSE 0
    END
    AS pct_dead
FROM
(SELECT
  c.oid,
  N.nspname,
  C.relname,
  pg_stat_get_tuples_inserted(C.oid) AS n_tup_ins,
  pg_stat_get_tuples_updated(C.oid) AS n_tup_upd,
  pg_stat_get_tuples_deleted(C.oid) AS n_tup_del,
  pg_stat_get_live_tuples(C.oid) AS n_live_tup,
  pg_stat_get_dead_tuples(C.oid) AS n_dead_tup,
  C.reltuples AS reltuples,
  round(current_setting('autovacuum_vacuum_threshold')::integer
    + current_setting('autovacuum_vacuum_scale_factor')::numeric * C.reltuples)
    AS av_threshold,
  date_trunc('day',greatest(pg_stat_get_last_vacuum_time(C.oid),pg_stat_get_last_autovacuum_time(C.oid)))::date AS last_vacuum,
  date_trunc('day',greatest(pg_stat_get_last_analyze_time(C.oid),pg_stat_get_last_analyze_time(C.oid)))::date AS last_analyze
 FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE C.relkind IN ('r', 't')
    AND N.nspname NOT IN ('pg_catalog', 'information_schema') AND
    N.nspname !~ '^pg_toast'
) AS av
ORDER BY n_dead_tup DESC
LIMIT 24
;


