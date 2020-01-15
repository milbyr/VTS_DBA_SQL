set lines 120 pages 100
col sql_text form a120
select SQL_TEXT
from v$sqltext
where address in ( select sql_address
from v$session
where sid = &1)
order by piece
/

