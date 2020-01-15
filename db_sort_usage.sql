set pages 100
col user form a8
break on report
compute sum of Mb on report

select user,session_num, SQLADDR, blocks , blocks *8 /1024 Mb
from V$SORT_USAGE
order by blocks, session_num;

break off
prompt 'lookup the sqltext of the lagest sort - enter the sql_addr'

SELECT SQL_TEXT FROM V$SQLTEXT
WHERE ADDRESS = '&1'
ORDER BY PIECE;

