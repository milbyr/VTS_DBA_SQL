set head off lines 100 pages 0
prompt 'OS processes for Developer logged in as APPS'
select '-- kill -9 ' ||p.spid, s.logon_time
from v$process p, v$session s
where p.addr = s.paddr
and sid  in ( select sid
    from v$session
    where module like 'SQL Developer%'
      and username = 'APPS');

prompt 'DB sessions'
select 'alter system kill session '''||sid||','||serial# ||''';' 
--, module
--, action
from v$session
where module like 'SQL Developer%'
 and username = 'APPS';

prompt 'OS processes for Developer NOT logged  in as APPS'
select '-- kill -9 ' ||p.spid, s.logon_time
from v$process p, v$session s
where p.addr = s.paddr
and sid  in ( select sid
    from v$session
    where module like 'SQL Developer%'
      and username <> 'APPS'
      and logon_time < trunc(sysdate)-1
     );

prompt 'DB sessions'
select 'alter system kill session '''||sid||','||serial# ||''';' 
--, module
--, action
, to_char(logon_time, 'dd-mon-yy hh24:mi') logon_date
from v$session
where module like 'SQL Developer%'
 and username <> 'APPS'
 and logon_time < trunc(sysdate)-1;
