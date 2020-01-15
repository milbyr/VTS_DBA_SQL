--col value form 999,999,999
col sid form 999999
col inst_id form 9
col module form a35
col ID form a6
set lines 200
set pages 100


WITH T as (select *
from (
  select INST_ID
    , sid
    , value
  from gv$sesstat
  where STATISTIC# = ( 
    select STATISTIC# 
    from v$statname 
    where name = 'CPU used by this session'
    -- 'OS User level CPU time'
    -- 'OS System call CPU time'
    --where name = 'physical reads'
    -- where name = 'physical writes'
  ) 
  order by value desc)
  where rownum <= 10
)
select S.sid ||'@' || S.inst_id ID
  , s.action, s.module, T.value, to_char(s.logon_time, 'dd-mon-yy hh24:mi:ss') day
from gv$session S, T
where S.sid = T.sid
  and S.inst_id = T.inst_id
order by T.value desc;

