select s.username, s.sid, s.serial#,p.spid
, to_char(s.logon_time, 'dd-mon-yy-hh24:mi') day
, s.module, action, s.sql_id
from v$process p, v$session s
where p.addr = s.paddr
  and p.spid = &1;

