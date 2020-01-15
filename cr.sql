set lines 160 pages 200 trims on
col user_concurrent_program_name form a50 word wrap
alter session set nls_date_format='dd-mon-yy hh24:mi';

select request_id, status_code, phase_code, actual_start_date
, ACTUAL_COMPLETION_DATE
, round( (ACTUAL_COMPLETION_DATE-actual_start_date) * 24, 2)  hours
, REQUESTED_BY
, user_concurrent_program_name 
from apps.fnd_concurrent_requests CR
   , apps.fnd_concurrent_programs_vl P
where request_id = &1
  and CR.concurrent_program_id = P.concurrent_program_id
/
