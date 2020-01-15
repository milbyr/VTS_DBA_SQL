conn / as sysdba
startup nomount;
alter database mount standby database;
alter database recover managed standby database disconnect;

set pages 100
alter session set nls_date_format='dd-mon-yy hh24:mi:ss';
-- alter database recover managed standby database  nodelay disconnect;


prompt the dataguard status
select * from v$dataguard_status;

prompt the switch-over status
select switchover_status from v$database;

exit
