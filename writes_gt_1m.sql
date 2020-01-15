-- Modification:
-- 20080204 R.Milby created to find the sql generating ALFs
-- - - - - - - - - - - - - - - - - - - - - - - - - - -
set serveroutput on

col value form 999,999,999

declare

  V_MOD varchar2(200);
  V_TIME varchar2(200);
  V_MACHINE varchar2(200);
  V_OSUSER varchar2(200);
  V_USERNAME varchar2(200);

  cursor top_reads is
    select * 
    from (
      select INST_ID, sid, value
      from gv$sesstat
      where STATISTIC# = ( 
        	select STATISTIC# 
	        from v$statname 
--     		 where name = 'physical reads'
	       where name = 'physical writes')
        and (inst_id,sid) not in ( 
		select inst_id,sid 
		from gv$session
		where type = 'BACKGROUND' )
      order by value desc) 
    where rownum <= 10
      and value > 100000;


Begin
  dbms_output.put_line( 'sid@instance  write count     module       logon time         machine    osuser username');
  for cur_r in top_reads loop
    select module , to_char(logon_time, 'dd-mon-yy hh24:mi:ss') , machine, osuser, username
      into V_MOD , V_TIME, V_MACHINE, V_OSUSER, V_USERNAME
    from gv$session
    where sid = cur_r.sid
      and inst_id = cur_r.inst_id;
  
    dbms_output.put_line('  '||lpad(cur_r.sid,10,' ')||' @ '||cur_r.inst_id 
           ||'       '||cur_r.value||'    '||V_MOD ||' '||V_TIME
         ||' '||V_MACHINE ||' '||V_OSUSER ||' '|| V_USERNAME );

  end loop;

end;
/

