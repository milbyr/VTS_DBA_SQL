REM ##############################################
REM ## conc_req_by_user.sql                     ##
REM ##                                          ##
REM ## Parameters : Full Username i.e. CLBROON  ##
REM ##                                          ##
REM ## Provides an ordered  list of concurrent  ##
REM ## jobs run by a specific user              ##
REM ##                                          ##
REM ## Version History                          ##
REM ## 1.0 21/11/2007 G.Dickson                 ##
REM ##                                          ##
REM ##############################################

col USER_CONCURRENT_PROGRAM_NAME form A35
col argument_text form A25
col user_name form A15
col Wait_time_seconds heading WAIT|TIME|(s) form 99999
col Execution_time_seconds heading RUN|TIME|(s) form 9999
col user_name form A7

Set lines 180
set pages 40

select  f.request_id, p.user_concurrent_program_name, 
        to_char(f.REQUESTED_START_DATE,'DD-MON-YYYY HH24:MI:SS') Request_Time,
        (f.actual_start_date - f.REQUESTED_START_DATE) * 86400 Wait_time_seconds,
        to_char(f.actual_start_date,'DD-MON-YYYY HH24:MI:SS') START_TIME, 
        to_char(f.ACTUAL_COMPLETION_DATE,'DD-MON-YYYY HH24:MI:SS') COMPLETION,
        (f.ACTUAL_COMPLETION_DATE - f.actual_start_date) * 86400 Execution_time_seconds,
        f.argument_text, u.user_name
from applsys.fnd_concurrent_requests f, 
     applsys.fnd_concurrent_programs_tl p,
     applsys.fnd_user u
where
p.concurrent_program_id=f.concurrent_program_id 
and f.requested_by = u.user_id 
and u.user_name = '&Username'
order by f.actual_start_date;

