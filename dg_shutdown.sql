conn / as sysdba
alter database recover managed standby database cancel;
shutdown
exit
