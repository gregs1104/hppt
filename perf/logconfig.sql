 SELECT
   'version'::text AS "name",
   '' AS source,
   version() AS "current_setting"
 UNION ALL
 SELECT
   name,source,current_setting(name)
 FROM pg_settings 
 WHERE (NOT source='default' AND NOT name IN
   ('config_file','data_directory','hba_file','ident_file',
   'log_timezone','DateStyle','lc_messages','lc_monetary',
   'lc_numeric','lc_time','timezone_abbreviations',
   'default_text_search_config','application_name',
   'transaction_deferrable','transaction_isolation',
   'transaction_read_only'))
   OR NAME IN ('log_destination','logging_collector','silent_mode','redirect_stderr','syslog_facility','syslog_ident')
;
