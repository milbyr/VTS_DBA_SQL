select request_id
  , phase_code
  , status_code
  , to_char(actual_start_date,'dd-mon-yy hh24:mi:ss') actual_start
  , argument_text
from apps.fnd_concurrent_requests cr
where ORACLE_SESSION_ID in (
select audsid from v$session
where sid = &1)
/

