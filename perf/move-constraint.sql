SELECT
--tablename, 
--indexname,
--indexdef 

'ALTER INDEX ' || indexname || ' RENAME to old_' || indexname || ';  '
|| indexdef || ';  ' ||
'ALTER TABLE ' || tablename || ' DROP CONSTRAINT old_' || indexname || ',' ||
'ADD CONSTRAINT ' || indexname || ' UNIQUE USING INDEX ' || indexname || '  ;'

FROM pg_indexes WHERE tablename='users'
AND tablespace IS NULL
;
