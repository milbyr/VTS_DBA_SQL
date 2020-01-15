col machine form a8
col module form a20
col action form a20
col sid form a20
set lines 180

select 
  CR.request_id
  , CR.phase_code
  , CR.status_code
  , S.sid ||'@'|| inst_id sid
  , S.serial#
  , S.machine
  , S.module
  , S.action
  , to_char(S.logon_time,'dd-mon-yy hh24:mi:ss') logon_time
from gv$session S 
  , apps.fnd_concurrent_requests CR
where 
 CR.oracle_session_id = S.audsid (+)
  and CR.request_id = &1
  -- and CR.phase_code = 'R'
order by S.logon_time desc
/
