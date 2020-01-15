set lines 140 pages 999 verify off trimout on trimspool on
alter session set nls_date_format = 'YY-MM-DD HH24:MI:SS';

column sid             format 99999999 wrap     heading "Session|ID"
column program         format a30      truncate heading "Program, first 30 chars"
column machine         format a20      truncate heading "Machine"
column logon_time      format date     wrap     heading "Logon|Time"
column status          format a2       truncate heading "St|at|us"
column since_last_call format a15      wrap     heading "Since|last|call"
column client_process  format a12      wrap     heading "Client|Process"
column server_process  format a12      wrap     heading "Server|Process"

select s.sid                     sid,
       s.program                 program,
       nvl(s.machine,s.terminal) machine,
       s.logon_time              logon_time,
       s.status                  status,
       trunc(last_call_et/3600/24)||'d '||
        mod( trunc( (last_call_et/3600/24)  *    24 ), 24)||'h '||
        mod( trunc( (last_call_et/3600/24 ) *  1440 ), 60)||'m '||
        mod( trunc( (last_call_et/3600/24 ) * 86400 ), 60)||'s' since_last_call,
       s.process                 client_process,
       p.spid                    server_process
from   v$session s,
       v$process p
where  s.type = 'USER'
and    s.sid != sys_context('USERENV','SID')
and    s.paddr = p.addr
order  by last_call_et asc;

ACCEPT v_sid NUMBER DEFAULT -1 PROMPT 'Enter "SID" to search for (e.g. 123456, default -1): '

column session_details format a999 heading "Session Detail"

with tables_accessed
as (select rtrim (xmlagg (xmlelement (e, table_name || ',')).extract ('//text()'), ',') tables
    from   (select object_name as table_name
            from   v$sql_plan
            where  sql_id = (select nvl(sql_id,prev_sql_id) from v$session where sid = &v_sid )
            and    object_type like '%TABLE%'
            union
            select table_name
            from   dba_indexes
            where (index_name,
                   owner) in (select distinct
                                     object_name,
                                     object_owner
                              from   v$sql_plan
                              where  sql_id = (select nvl(sql_id,prev_sql_id) from v$session where sid = &v_sid)
                              and    object_type not like '%TABLE%'))),
     string_builder
as (select rpad('SID:',20)||s.sid||'~'||
           rpad('Serial#:',20)||s.serial#||'~'||
           rpad('Client Process:',20)||s.process||'~'||
           rpad('Server Process:',20)||p.spid||'~'||
           rpad('Username:',20)||s.username||'~'||
           rpad('OS User:',20)||s.osuser||'~'||
           rpad('Machine:',20)||s.machine||'~'||
           rpad('Terminal:',20)||s.terminal||'~'||
           rpad('Program:',20)||s.program||'~'||
           rpad('Module:',20)||s.module||'~'||
           rpad('Logon Time:',20)||to_char(s.logon_time,'YYYY-MM-DD HH24:MI:SS')||'~'||
           rpad('Last Call (secs):',20)||s.last_call_et||'~'||
           rpad('Status:',20)||s.status||'~'||
           rpad('Known SQL ID:',20)||nvl(s.sql_id,s.prev_sql_id)||':'||nvl(sql_child_number,prev_child_number)||'~'||
           rpad('Known SQL Text:',20)||(select substr(sql_text,1,110) from v$sqlarea where sql_id = nvl(s.sql_id,s.prev_sql_id))||'~'||
           rpad('Known SQL Stats:',20)||(select 'Disk GB: '||round(disk_reads*8/1024/1024,0)||', Log GB: '||round(buffer_gets*8/1024/1024,0)||', Elapsed Secs '|| round(elapsed_time/1000000,0)||', CPU Secs '|| round(cpu_time/1000000,0)||', Exec '||executions from v$sqlarea where sql_id = nvl(s.sql_id,s.prev_sql_id))||'~'||
           rpad('Known SQL Tables:',20)||t.tables||'~'||
           rpad('Killer (careful!):',20)||'--alter system kill session '''||s.sid||','||s.serial#||''' immediate ;'||'~'||
           '' as string
    from   v$session s,
           v$process p,
           tables_accessed t
    where  s.sid    = &v_sid
    and    s.paddr  = p.addr)
SELECT regexp_substr(string, '[^~]+', 1, LEVEL) session_details
FROM   string_builder CONNECT BY LEVEL <= length(string)-length(REPLACE(string, '~', '')) + 1;
