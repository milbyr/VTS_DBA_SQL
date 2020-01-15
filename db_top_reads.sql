col value form 999,999,999

select * 
from (
  select INST_ID, sid, value
  from gv$sesstat
  where STATISTIC# = ( 
    select STATISTIC# 
    from v$statname 
    where name = 'physical reads'
  -- where name = 'physical writes'
  ) 
  order by value desc) 
where rownum <= 10
/

