col opname form a40 wrap word

select OPNAME, SOFAR, TOTALWORK  
, round(SOFAR * 100 / TOTALWORK,1) pct
from v$session_longops
where SOFAR <> TOTALWORK
  and TOTALWORK > 0
/

