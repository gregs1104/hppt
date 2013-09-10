SELECT 
  cast(date_trunc('seconds',now()) AS timestamp without time zone) AS collected,
  tmp2.locktype,
  tmp2.mode,
  COALESCE(sum(tmp2.count),0) AS number,
  relation,
  relname
FROM 
  (VALUES ('accesssharelock'),('rowsharelock'),('rowexclusivelock'),
   ('shareupdateexclusivelock'),('sharelock'),('sharerowexclusivelock'),
    ('exclusivelock'),('accessexclusivelock')) 
    AS tmp(mode)
LEFT JOIN
(
	SELECT locktype,mode,count(*) AS count,relation
	FROM pg_locks 
		WHERE database=(SELECT oid from pg_database where datname='dbXX') 
	GROUP BY locktype,mode,relation
) AS tmp2 ON lower(tmp.mode)=lower(tmp2.mode)
LEFT OUTER JOIN pg_class ON (tmp2.relation = pg_class.oid)
GROUP BY collected,relname,relation,tmp2.locktype,tmp2.mode
ORDER BY collected,relname,relation,tmp2.locktype,tmp2.mode
;

