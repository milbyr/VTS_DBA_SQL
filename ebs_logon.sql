set pages 100
col user_name form a30
break on report

select user_name
  , to_char(LAST_LOGON_DATE, 'dd-mon-yy hh24:mi') LAST_LOGON_DATE
  , round((sysdate - LAST_LOGON_DATE)* 24,2) duration
from fnd_user
where LAST_LOGON_DATE > trunc(sysdate)
/
