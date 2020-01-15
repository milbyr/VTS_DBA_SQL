select phase_code, status_code, count(*)
from apps.fnd_concurrent_requests CR
where phase_code = 'P'
  and requested_start_date < sysdate
group by  phase_code, status_code
--order by actual_start_date
/
