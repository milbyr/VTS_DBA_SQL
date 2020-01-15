set pages 200 lines 120
col user_concurrent_program_name form a60 wrap word

alter session set nls_date_format='dd-mon-rr hh24:mi:ss';

select request_id, status_code, phase_code, requested_start_date, actual_start_date, user_concurrent_program_name, HAS_SUB_REQUEST, IS_SUB_REQUEST
from cr, fnd_concurrent_programs_vl P
where status_code in ('I','R')
  and requested_start_date > sysdate -2
  and CR.concurrent_program_id = P.concurrent_program_id
order by requested_start_date;
