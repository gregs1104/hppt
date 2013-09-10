#!/bin/bash
psql -c "select *,pg_xlogfile_name(replay_location) from pg_stat_replication" -x
