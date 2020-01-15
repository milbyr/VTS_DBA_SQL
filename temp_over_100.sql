set lines 200
col USERNAME for a15
col osuser for a15
col program for a35
col module for a25
col tablespace for a15

SELECT   b.TABLESPACE
--        , b.segfile#
--        , b.segblk#
        , ROUND (  (  ( b.blocks * p.VALUE ) / 1024 / 1024 ), 2 ) size_mb
        , a.SID
        , a.serial#
        , a.username
        , a.osuser
        , a.module
        , a.program
        , a.status
     FROM v$session a
        , v$sort_usage b
        , v$process c
        , v$parameter p
    WHERE p.NAME = 'db_block_size'
      AND ROUND (  (  ( b.blocks * (select value from v$parameter where name='db_block_size') ) / 1024 / 1024 ), 2 ) > 100
      AND a.saddr = b.session_addr
      AND a.paddr = c.addr
 ORDER BY b.blocks
        , b.TABLESPACE
        , b.segfile#
        , b.segblk#
/
