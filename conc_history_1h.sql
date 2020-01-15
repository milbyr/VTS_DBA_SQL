col APPLICATION_SHORT_NAME for a5
col ARGUMENT_TEXT for a50
set lines 200
col PROGRAM for a40
select  a.APPLICATION_SHORT_NAME
  , f.user_concurrent_program_name Program,
    (f.ACTUAL_COMPLETION_DATE - f.actual_START_DATE)*1440 Run_Time,
    to_char(f.actual_start_date,'DD-MON-YY HH24:MI:ss') Start_time,
    f.argument_text,
    f.REQUEST_ID,
    f.phase_code,
    f.status_code
from FND_CONC_REQ_SUMMARY_V f , fnd_application a
  where a.APPLICATION_ID = f.PROGRAM_APPLICATION_ID
 and f.user_concurrent_program_name like '%&CCProgram_Name%'
 and f.REQUEST_DATE > (sysdate - (1/24))
 order by f.REQUEST_ID
--order by f.actual_start_date
/

