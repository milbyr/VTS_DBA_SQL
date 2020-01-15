SET LINES 160
SET PAGES 80

COL begin_interval_time FORMAT a25
COL end_interval_time   FORMAT a25

SELECT  DISTINCT 
        snap_id
       ,begin_interval_time
       ,end_interval_time
       ,sql_id
       ,plan_hash_value
       ,lines_in_plan
       ,cost
  FROM  (
        SELECT  sp.snap_id
               ,s.begin_interval_time
               ,s.end_interval_time
               ,sp.sql_id
               ,sp.plan_hash_value
               ,COUNT(*)             OVER( PARTITION BY sp.snap_id, sp.sql_id, sp.plan_hash_value )               lines_in_plan
               ,FIRST_VALUE( cost )  OVER( PARTITION BY sp.snap_id, sp.sql_id,sp.plan_hash_value ORDER BY sp.id ) cost
          FROM  sys.wrh$_sql_plan sp
               ,sys.wrm$_snapshot s
         WHERE  sp.sql_id  = '&sql_id'
           AND  sp.snap_id = s.snap_id (+)
        )
ORDER BY snap_id
/
