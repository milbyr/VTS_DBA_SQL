set pages 900 lines 200 trims on
break on hour  skip 1 on report
compute sum of cnt tott on report

PROMPT Concurrent Program Profile;
--
COLUMN hour         HEADING 'Date'              FORMAT A4;
COLUMN qn           HEADING 'Queue|Name'        FORMAT A25;
COLUMN cnt          HEADING 'Total|Jobs'        FORMAT 999,990;
COLUMN cntt         HEADING 'Total|Jobs'        FORMAT 999,990;
COLUMN tott         HEADING 'Total|Time(Min)'
COLUMN mint         HEADING 'Min|Time(Min)'
COLUMN avgt         HEADING 'Avg|Time(Min)'
COLUMN maxt         HEADING 'Max|Time(Min)'
COLUMN avgd         HEADING 'Avg|Delay(Min)'
COLUMN maxd         HEADING 'Max|Delay(Min)'
COLUMN utilisation  HEADING 'Queue|Utilisation(%)'

SELECT TO_CHAR(r.ACTUAL_START_DATE,'HH24') hour,
       q.concurrent_queue_name qn,
       COUNT(r.REQUEST_ID) cnt,
       round(SUM((r.ACTUAL_COMPLETION_DATE - r.ACTUAL_START_DATE)*(60*24)),1) tott,
       case when ( SUM((r.ACTUAL_COMPLETION_DATE - r.ACTUAL_START_DATE)*(60*24)) / workers.proc_mins)  > 1
         then '** ' || round(SUM((r.ACTUAL_COMPLETION_DATE - r.ACTUAL_START_DATE)*(60*24)) / workers.proc_mins * 100, 0) || ' **'
       else
           ' ' ||round(SUM((r.ACTUAL_COMPLETION_DATE - r.ACTUAL_START_DATE)*(60*24)) / workers.proc_mins * 100, 0) ||' '
       end as utilisation,
       round(MIN((r.ACTUAL_COMPLETION_DATE - r.ACTUAL_START_DATE)*(60*24)),1) mint,
       round(AVG((r.ACTUAL_COMPLETION_DATE - r.ACTUAL_START_DATE)*(60*24)),1) avgt,
       round(MAX((r.ACTUAL_COMPLETION_DATE - r.ACTUAL_START_DATE)*(60*24)),1) maxt,
       ROUND(AVG((r.ACTUAL_START_DATE - r.REQUESTED_START_DATE)*(60*24)),1) avgd,
       ROUND(MAX((r.ACTUAL_START_DATE - r.REQUESTED_START_DATE)*(60*24)),1) maxd
  FROM fnd_concurrent_requests r,
       fnd_concurrent_processes p,
       fnd_concurrent_programs cp,
       fnd_concurrent_queues q,
       fnd_concurrent_programs_tl cptl,
       ( select CONCURRENT_QUEUE_ID, count(*) * 60  proc_mins
         from fnd_concurrent_processes
where PROCESS_STATUS_CODE = 'A'
group by CONCURRENT_QUEUE_ID ) workers
 WHERE TRUNC(r.ACTUAL_START_DATE) = trunc(sysdate)
  AND r.phase_code = 'C'
  AND R.controlling_manager = P.concurrent_process_id
  AND p.concurrent_queue_id = q.concurrent_queue_id
  AND p.queue_application_id = q.application_id
  AND r.program_application_id = cp.application_id
  AND r.concurrent_program_id = cp.concurrent_program_id
  AND cp.application_id = cptl.application_id
  AND cp.concurrent_program_id = cptl.concurrent_program_id
and p.concurrent_queue_id = workers.CONCURRENT_QUEUE_ID
GROUP BY TO_CHAR(r.ACTUAL_START_DATE,'HH24'), q.concurrent_queue_name, workers.proc_mins
ORDER BY hour, q.concurrent_queue_name;
