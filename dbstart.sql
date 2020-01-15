connect / as sysdba
prompt the following query should fail if the database instance is down.

select name from v$database;

startup
exit
