set pages 100 lines 160 trims on
col MESSAGE form a40 wrap word

alter session set nls_date_format='dd-mon-yy hh24:mi:ss';

select 
  TIMESTAMP
  ,DEST_ID 
  ,SEVERITY      
  , FACILITY                 
--  , ERROR_CODE
  , MESSAGE
from v$dataguard_status
order by TIMESTAMP;

prompt The gap between the primary and the detination
select * from v$archive_gap;


col dest_name form a20
select DEST_NAME, STATUS, FAILURE_COUNT, MAX_FAILURE, LOG_SEQUENCE
from v$archive_dest
where dest_id <=2
  and TIMESTAMP > sysdate - 4/24
/

prompt ALF process
select process,status,client_process,sequence#
from v$managed_standby;

prompt ALF differences
select ads.dest_id,max(sequence#) "Current Sequence",
         max(log_sequence) "Last Archived"
from v$archived_log al, v$archive_dest ad, v$archive_dest_status ads
where ad.dest_id=al.dest_id
  and al.dest_id=ads.dest_id
group by ads.dest_id;



SELECT ARCH.THREAD# "Thread"
  , ARCH.SEQUENCE# "Last Sequence Received"
  , APPL.SEQUENCE# "Last Sequence Applied"
  , (ARCH.SEQUENCE# - APPL.SEQUENCE#) "Difference"
  , round( ( arch.first_time - appl.first_time) * 24, 1) time_diff_hours
 FROM
 ( SELECT THREAD# ,SEQUENCE# , first_time 
   FROM V$ARCHIVED_LOG 
   WHERE (THREAD#,FIRST_TIME ) IN 
      ( SELECT THREAD#,MAX(FIRST_TIME) 
        FROM V$ARCHIVED_LOG 
        GROUP BY THREAD#)) ARCH,
 ( SELECT THREAD# ,SEQUENCE#, first_time  
   FROM V$LOG_HISTORY 
   WHERE (THREAD#,FIRST_TIME ) IN 
      ( SELECT THREAD#,MAX(FIRST_TIME) 
        FROM V$LOG_HISTORY 
        GROUP BY THREAD#)) APPL
 WHERE ARCH.THREAD# = APPL.THREAD#
--   and arch.dest_id = appl.dest_id
ORDER BY 1;
