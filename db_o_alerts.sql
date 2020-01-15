set pages 200 lines 160
col OBJECT_TYPE form a20
col SUBOBJECT_NAME form a40
col OBJECT_NAME form a60
col reason form a60 wrap word

select CREATION_TIME
  ,OBJECT_TYPE 
  ,SUBOBJECT_NAME
  ,OBJECT_NAME
  ,REASON 
from dba_outstanding_alerts
order by 1
/
