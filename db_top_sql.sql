set lines 200 pages 50

break on load on executes on sql_id on buffer_gets
PROMPT Most expensive top 10 SQL across all online history for Buffer Gets
PROMPT *******************************************************************
select substr(to_char(s.pct, '99.00'), 2) || '%'  load,
       s.sql_id,
       s.executions  executes,
       s.buffer_gets,
       p.sql_text
from  (select sql_id,
              address,
              buffer_gets,
              executions,
              pct,
              rank() over (order by buffer_gets desc)  ranking
       from   (select sql_id, address,
	              buffer_gets,
	              executions,
	              100 * ratio_to_report(buffer_gets) over ()  pct
	       from   sys.v$sql
	       where   command_type != 47)
       where   buffer_gets > 50 * executions)  s,
       sys.v$sqltext  p
where  s.ranking <= 20
and    p.address = s.address
order by 1 desc, 
         s.address, 
         p.piece asc;

prompt select * from table(dbms_xplan.display_cursor('&sql_id',0,'ALL'));
