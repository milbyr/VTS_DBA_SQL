set head on
set pages 50000
col lag_hours for 999,990.00
select
 sequence#,
 to_char(first_time, 'dd-mm-yyyy hh24:mi') DRTime,
 to_char(sysdate, 'dd-mm-yyyy hh24:mi') Now,
 round((sysdate-first_time)*24,2) lag_hours,
 decode(sign(round((sysdate-first_time)*24,2)-2 /* -2 Hour Threshold */ ),
                    1,'$L_CHECK_ERRROR :: DR Lag is over 2 hour ERROR Threshold',
                    'DR Lag is within 2 hour error Threshold') lag_error_status,
 decode(sign(round((sysdate-first_time)*24,2)-4 /* -4 Hour Threshold */ ),
                    1,'$L_CHECK_CRITICAL :: DR Lag is over 4 hour CRITICAL Threshold',
                    'DR Lag is within 4 hour CRITICAL Threshold') lag_critical_status
from
 v$archived_log
where
 sequence#=(select max(sequence#) from v$archived_log where applied='YES')
 and applied='YES'
/
