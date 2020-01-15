col owner form a8
col retries form a8
col enqueue form a6
col RETENTION form a6
col RETRY_DELAY form a5
col QUEUE_NAME form a20

set lines 150 pages 100

prompt 'WF Queue Information'

select q.OWNER OWNER, q.NAME QUEUE_NAME
  , o.STATUS QUEUE_STATUS, q.ENQUEUE_ENABLED ENQUEUE
  , q.DEQUEUE_ENABLED DEQUEUE, to_char(q.MAX_RETRIES) RETRIES
  , q.RETENTION, to_char(q.RETRY_DELAY) RETRY_DELAY
from   ALL_QUEUES q, DBA_OBJECTS o
where (q.NAME = o.OBJECT_NAME 
       and o.object_type = 'QUEUE') 
  and (q.NAME LIKE 'WF%' 
       OR q.NAME LIKE 'ECX%')
order by q.NAME
;
