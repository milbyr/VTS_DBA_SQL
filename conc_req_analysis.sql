select phase_code, to_char(actual_start_date, 'yyyy-mm-dd') day
, count(*)
, round(sum( actual_completion_date - actual_start_date ) * 24 * 60,2) tot_minutes
, round( (sum( actual_completion_date - actual_start_date ) * 24 * 60) / count(*),2) avg_minutes
from fnd_concurrent_requests
where concurrent_program_id = (
      select concurrent_program_id
      from apps.fnd_concurrent_programs_tl
      where user_concurrent_program_name = '&Conc_Pg_Name'
)
group by phase_code, to_char(actual_start_date, 'yyyy-mm-dd')
