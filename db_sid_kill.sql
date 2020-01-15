col sid form 99999999

select sid, serial#
  , action
  , to_char(logon_time,'dd-mon-yy hh24:mi') logon_time
from v$session
where sid = &1;

alter system kill session '&1,&2';

