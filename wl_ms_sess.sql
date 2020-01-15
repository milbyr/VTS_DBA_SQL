set lines 132
set pages 500
column module heading "Module Name" format a48;
column machine heading "Machine Name" format a30;
column process heading "Process ID" format a10;
prompt
prompt Weblogic Managed Server Connection Usage Per process and module
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

break on machine skip 1 on process on report
compute sum of count(*) on machine report

select
    machine ,  process, module
    ,count(*)
from v$session
where program like '%JDBC%'
group by machine, process, module
order by 1, 2, 3;

