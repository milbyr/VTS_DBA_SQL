set pages 100 lines 120

col file_name form a50
col mb form 999,999

break on report
compute sum of Mb auto_free_MB on report

prompt 'Enter the  tablespace name that is in question'
select file_name
  , bytes/1024/1024 Mb
  , autoextensible
  , maxbytes/1024/1024 MAX_Mb
  , decode(autoextensible, 'YES',round((maxbytes - bytes)/1024/1024,2),0) auto_free_MB
from dba_data_files
where tablespace_name = upper('&1')
order by file_name
/

select d.tablespace_name
, d.total_mb
, f.free_mb
, round(f.free_mb/d.total_mb * 100 ,0) PCT_FREE
, d.auto_mb
from (select tablespace_name
, round( sum(bytes)/1024/1024,2) total_Mb
, round( sum(maxbytes)/1024/1024,2) auto_Mb
from dba_data_files
group by tablespace_name
union
select tablespace_name
, round( sum(bytes)/1024/1024,2) total_Mb
, round( sum(maxbytes)/1024/1024,2) auto_Mb
from dba_temp_files
group by tablespace_name
) d,
(select tablespace_name, round(sum(bytes)/1024/1024,0) free_mb
from dba_free_space
group by tablespace_name ) f
where d.tablespace_name = f.tablespace_name (+)
  and d.tablespace_name = upper('&1')
--  and round(f.free_mb/d.total_mb * 100 ,0) < 10
--  and d.total_mb > 20
order by 4 desc, 3 desc
--order by 1
/
