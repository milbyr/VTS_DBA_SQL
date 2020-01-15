-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
-- Quick way to find the execution plan of a long waiting session
-- R.Milby  20070717
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

col username form a12
col wait_class form a15
col sid form 9999
set lines 120 pages 200
set echo off verify off

prompt 'The top 10 waiting sessions'
prompt '  '

select * 
from (
  select  a.sid,
          b.username,
  	  b.SQL_ID,
  	  b.SQL_CHILD_NUMBER,
          a.wait_class,
          a.total_waits,
          round((a.time_waited / 100),0) time_waited_secs
  from    sys.v_$session_wait_class a,
          sys.v_$session b
  where   b.sid = a.sid and
          b.username is not null and
          a.wait_class != 'Idle'
  	and round((a.time_waited / 100),0) != 0
  order by round((a.time_waited / 100),0) desc )
  where rownum <= 10;


prompt 'Use the SQL_ID and SQL_CHILD_NUMBER values to recover the actual execution plan used'
prompt '  '

select * 
from table(DBMS_XPLAN.DISPLAY_CURSOR('&SQL_ID',&sql_child_number )) ;

