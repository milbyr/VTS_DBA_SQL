
 col value new_value dir_param
 col F new_value trc_fn

  select value
  from v$parameter
  where name = 'user_dump_dest';


  select s.sid
    , s.serial# 
    , '&dir_param/' ||lower('$ORACLE_SID') ||'_ora_'||p.spid||'.trc'  filename
  from v$session s, v$process p
  where s.sid = &1
  and p.addr = s.paddr;

exec dbms_system.set_sql_trace_in_session(&1,&2,true);

prompt remember to user exec dbms_system.set_sql_trace_in_session(&1,&2,false);

