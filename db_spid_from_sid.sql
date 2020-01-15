
set lines 180

select s.username, s.sid, s.serial#,p.spid
, to_char(s.logon_time, 'dd-mon-yy-hh24:mi') day
from v$process p, v$session s
where p.addr = s.paddr
and sid = &1
/

