set lines 200 pages 200

select DF.tablespace_name
  , round((DF.bytes - FS.bytes )/1024/1024, 1) Used_MB
  , round(FS.bytes/1024/1024,1) free_MB
  , round((DF.bytes)/1024/1024,1) total_MB
  , round(((FS.bytes)/ (DF.bytes) * 100 ),0) pct_free
  , round((DF.maxbytes)/1024/1024,0) max_auto_MB
  , round((DF.auto_free_bytes)/1024/1024,0) auto_free_MB
from
 ( select tablespace_name
    , sum(bytes) bytes
    , sum(maxbytes) maxbytes
    , sum(auto_free_bytes) auto_free_bytes
   from (
      select tablespace_name
        , file_name
        , bytes
      --  , autoextensible
        , maxbytes
        , decode(autoextensible, 'YES',round((maxbytes - bytes),0),0) auto_free_bytes
      from dba_data_files
    )
    group by tablespace_name
  ) DF,
  ( select tablespace_name, sum(bytes) bytes
    from dba_free_space
    group by tablespace_name
  ) FS
where DF.tablespace_name = FS.tablespace_name (+)
--  and  DF.tablespace_name = '1'
order by round(((FS.bytes)/ (DF.bytes) * 100 ),1) desc
/
