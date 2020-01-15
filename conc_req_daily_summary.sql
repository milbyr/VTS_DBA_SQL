set pages 100 lines 200

col APPLICATION_SHORT_NAME form a5 head 'mod'
col user_concurrent_program_name form a50 wrap word head 'CP Name'
col ave_Wait_time_mins form 9999.99 head 'avg|wait|mins'
col max_Execution_time_mins form 9999.99 head 'max|exec|mins'
col avg_Execution_time_mins form 9999.99 head 'avg|exec|mins'
col min_Execution_time_mins form 9999.99 head 'min|exec|mins'

break on APPLICATION_SHORT_NAME skip 1 on report

select  a.APPLICATION_SHORT_NAME
  , f.user_concurrent_program_name,
    round( avg((f.actual_start_date - f.REQUESTED_START_DATE) * 1440),2) ave_Wait_time_mins,
    round( max((f.ACTUAL_COMPLETION_DATE - f.actual_start_date) * 1440),2) max_Execution_time_mins,
    round( avg((f.ACTUAL_COMPLETION_DATE - f.actual_start_date) * 1440),2) avg_Execution_time_mins,
    round( min((f.ACTUAL_COMPLETION_DATE - f.actual_start_date) * 1440),2) min_Execution_time_mins
  , count(*) qty 
  , round( sum((f.ACTUAL_COMPLETION_DATE - f.actual_start_date) * 1440),2) tot
from FND_CONC_REQ_SUMMARY_V f
  , fnd_application a
where  f.actual_completion_date between trunc(sysdate -1) and trunc(sysdate)
  and a.APPLICATION_ID = f.PROGRAM_APPLICATION_ID
group by a.APPLICATION_SHORT_NAME
  , f.user_concurrent_program_name
order by 1

/
