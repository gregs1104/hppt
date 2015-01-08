#!/bin/bash

# Copyright 2013-2015 Gregory Smith gsmith@westnet.com

# TODO Enable selecting the order by size version with a command line option

if [ -n "${HPPTDATABASE}" ] ; then
    db="-d ${HPPTDATABASE}"
fi

# Order by table reads
psql $db ${HPPTOPTS} -c "
SELECT
  current_timestamp as collected,
  TS.spcname tbl_space,
  schemaname AS nspname,
  statio.relname AS tablename,
  statio.indexrelname AS indexname,
  pg_relation_size(indexrelid) AS size,
  idx_blks_read AS rel_blks_read,
  idx_blks_hit AS rel_blks_hit,
  idx_blks_hit+idx_blks_read AS rel_blks,
  CASE WHEN (idx_blks_hit+idx_blks_read)>0 THEN round(100*idx_blks_hit/(idx_blks_hit+idx_blks_read)) ELSE 0 END AS hit_pct
FROM pg_statio_user_indexes statio
  JOIN pg_class C ON (C.oid = indexrelid)
  LEFT JOIN
    pg_tablespace TS ON (C.reltablespace = TS.oid)
WHERE (idx_blks_hit + idx_blks_read)>0
UNION
SELECT
  current_timestamp as collected,
  TS.spcname tbl_space,
  schemaname AS nspname,
  statio.relname AS tablename,
  NULL AS indexname,
  pg_relation_size(relid) AS size,
  heap_blks_read AS rel_blks_read,
  heap_blks_hit AS relk_blks_hit,
  heap_blks_hit+heap_blks_read AS rel_blks,
  CASE WHEN (heap_blks_hit+heap_blks_read)>0 THEN round(100*heap_blks_hit/(heap_blks_hit+heap_blks_read)) ELSE 0 END AS hit_pct
FROM pg_statio_user_tables statio
  JOIN pg_class C ON (C.oid = relid)
  LEFT JOIN
    pg_tablespace TS ON (C.reltablespace = TS.oid)
WHERE (heap_blks_hit + heap_blks_read)>0
ORDER BY rel_blks_read DESC LIMIT 50;
"

exit 0

# Order by size

psql $db ${HPPTOPTS} -c "
SELECT
--  schemaname AS nspname,
  relname AS tablename,
  indexrelname AS indexname,
  pg_relation_size(indexrelid) AS size,
  idx_blks_read AS rel_blks_read,
  idx_blks_hit AS rel_blks_hit,
  idx_blks_hit+idx_blks_read AS rel_blks,
  CASE WHEN (idx_blks_hit+idx_blks_read)>0 THEN round(100*idx_blks_hit/(idx_blks_hit+idx_blks_read)) ELSE 0 END AS hit_pct
FROM pg_statio_user_indexes
WHERE (idx_blks_hit + idx_blks_read)>0
UNION
SELECT
--  schemaname AS nspname,
  relname AS tablename,
  NULL AS indexname,
  pg_relation_size(relid) AS size,
  heap_blks_read AS rel_blks_read,
  heap_blks_hit AS relk_blks_hit,
  heap_blks_hit+heap_blks_read AS rel_blks,
  CASE WHEN (heap_blks_hit+heap_blks_read)>0 THEN round(100*heap_blks_hit/(heap_blks_hit+heap_blks_read)) ELSE 0 END AS hit_pct
FROM pg_statio_user_tables
WHERE (heap_blks_hit + heap_blks_read)>0
ORDER BY size DESC LIMIT 50;
"

