set pages 200 lines 160 trims on feedback off echo off head off verify off

accept KRONOS_ENV prompt 'Enter the Kronos environment you are pointing to '
spool /tmp/kronos_&KRONOS_ENV..sql

select 'drop public database link '||db_link||';'
from dba_db_links
where db_link like 'KRONOS_%';


prompt create public database link kronos_&KRONOS_ENV
prompt connect to kronos_odbc_&KRONOS_ENV
prompt identified by S0lsth31m
prompt using 'KRONOS_&KRONOS_ENV';;

select 'drop synonym '||owner||'.'||synonym_name||';'
from dba_synonyms
where owner = 'XXLBG';

select 'create synonym '||owner||'.'||synonym_name,
'for dbo.'||synonym_name ||'@KRONOS_&KRONOS_ENV;'
from dba_synonyms
where owner = 'XXLBG'
  and DB_LINK like 'KRONOS%';


spool off
prompt  'run the following  @/tmp/kronos_&KRONOS_ENV.sql'

--@/tmp/kronos_&KRONOS_ENV..sql


prompt select count(*) from XXLBG.UKCUSTOM_DELEGATION_SETS;

exit
