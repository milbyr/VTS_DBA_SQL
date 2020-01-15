set trimspool on
set trim on
set pages 0
set long 10000000
set longchunksize 10000000
set linesize 200
set termout off

spool sql_monitor_for_&sql_id.htm 

variable my_rept CLOB;

BEGIN
   :my_rept := dbms_sqltune.report_sql_monitor(sql_id => '&sql_id', report_level => 'ALL', type => 'HTML'); 
END;
/ 

print :my_rept

spool off; 
set termout on
