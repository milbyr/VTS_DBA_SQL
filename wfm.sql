set pages 200 lines 160 trims on

col PARAMETER_VALUE form a50
col DISPLAY_NAME form a40 wrap word

select v.parameter_id , N.DISPLAY_NAME, v.parameter_value
from fnd_svc_comp_param_vals V, FND_SVC_COMP_PARAMS_TL N
where V.parameter_id = N.parameter_id
  and v.component_id = 10006
--  and V.parameter_id  in ( 10018, 10026, 10033, 10043, 10044, 10053, 10057, 10029, 10073, 10120, 10126, 10163)
order by 1;



prompt This is the status of the WF services
select component_type, component_name, Component_status
from fnd_svc_components
where component_type like 'WF%'
order by 1 desc,2,3;


prompt This is the WF services log files'
select fl.meaning,fcp.process_status_code, decode(fcq.concurrent_queue_name,'WFMLRSVC', 'mailer container',
'WFALSNRSVC','listener container',fcq.concurrent_queue_name),
  fcp.concurrent_process_id,os_process_id, fcp.logfile_name
from fnd_concurrent_queues fcq, fnd_concurrent_processes fcp , fnd_lookups fl
where fcq.concurrent_queue_id=fcp.concurrent_queue_id and fcp.process_status_code='A'
  and fl.lookup_type='CP_PROCESS_STATUS_CODE' and fl.lookup_code=fcp.process_status_code
  and concurrent_queue_name in('WFMLRSVC','WFALSNRSVC')
order by fcp.logfile_name;

