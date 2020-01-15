UNDER WHICH MANAGER THE REQUEST WAS RUN

SELECT
b.user_concurrent_queue_name
FROM
fnd_concurrent_processes a
,fnd_concurrent_queues_vl b
,fnd_concurrent_requests c
WHERE 1=1
AND a.concurrent_queue_id = b.concurrent_queue_id
AND a.concurrent_process_id = c.controlling_manager
AND c.request_id = &request_id;


B) USER SESSION BY CONCURRENT MANAGER REQUEST ID

set linesize 132
col pid format 9999 heading 'PID'
col spid format a6 heading 'SERVER|PID'
col sid format 9999 heading 'SID'
col serial# format 99999 heading 'SERIAL'
col process format a6 heading 'CLIENT|PID'
col osuser format a8 heading 'OS|USERNAME'
col username format a10 heading 'ORACLE|USERNAME'
col log_per_sec format 999999 heading 'LOG|PER|SEC'
col logical format b9999999999 heading 'LOGICAL|READS'
col phy_per_sec format b9999 heading 'PHY|PER|SEC'
col physical_reads format b99999999 heading 'PHYSICAL|READS'
col audsid format b9999999 heading 'AUDIT|SESSION'
col program format a32 heading 'PROGRAM NAME'
col logon_time format a8 heading 'LOGON|TIME'
col duration format a8 heading 'DURATION'
col last_call_min format 9999 heading 'LAST|CALL|MIN'
col status format a1 heading 'S'
rem
rem break on report
rem compute sum of log_per_sec phy_per_sec on report
rem
select s.process,
p.spid,
s.sid,
s.serial#,
s.osuser,
s.username,
( i.block_gets + i.consistent_gets ) /
( ( sysdate - s.logon_time ) * 86400 ) log_per_sec,
i.block_gets + i.consistent_gets logical,
physical_reads /
( ( sysdate - s.logon_time ) * 86400 ) phy_per_sec,
i.physical_reads,
to_char( trunc(sysdate) + ( sysdate - s.logon_time ), 'hh24:mi:ss' ) duration,
s.last_call_et/60 last_call_min,
decode( s.status, 'ACTIVE', '*', 'INACTIVE', null, 'KILLED', 'K', '?' ) status,
s.module program
from v$process p, v$session s, v$sess_io i,
applsys.fnd_concurrent_requests r
where i.sid = s.sid
and s.paddr = p.addr
and r.oracle_session_id = s.audsid
and r.request_id = &request;


C) DETAILS OF ALL FND CONCURRENT QUEUES

set lines 132

col user_concurrent_queue_name format a30 heading 'QUEUE NAME'
col manager_type format a4 heading 'TYPE'
col batch_queue format 999 heading 'BATCH|QUEUE'
col tm_queue format 99 heading 'TM|QUEUE'
col running_processes format 99 heading 'RUN|JOB'
col max_processes format 99 heading 'MAX|JOB'
col min_processes format 99 heading 'MIN|JOB'
col target_processes format 99 heading 'TARGET|JOB'
col sleep_seconds format 999 heading 'SLEEP|SECS'
col sleep_fast format a1 heading 'F'
col cache_size format 9999 heading 'CACHE|SIZE'
rem
break on report
compute sum of batch_queue tm_queue running_processes max_processes on report
rem
select qt.user_concurrent_queue_name,
manager_type,
decode( manager_type, '1', running_processes ) batch_queue,
decode( manager_type, '3', running_processes ) tm_queue,
running_processes,
max_processes,
min_processes,
target_processes,
sleep_seconds,
decode( sleep_seconds, greatest( 30, sleep_seconds ), null, '*' ) sleep_fast,
cache_size
from applsys.fnd_concurrent_queues_tl qt,
applsys.fnd_concurrent_queues q
where q.application_id = qt.application_id
and q.concurrent_queue_id = qt.concurrent_queue_id
and userenv('lang') = qt.language
order by qt.user_concurrent_queue_name;
D) WHAT IS CURRENTLY RUNNING FOR ALL CONCURRENT MANAGER QUEUES

set lines 132

col request_class_name format a20 heading 'REQUEST CLASS NAME'
col program format a26 trunc heading 'Program'
col manager format a16 trunc heading 'Manager|Queue'
col phase_code format a1 heading 'P'
col status_code format a1 heading 'S'
col concurrent_program_name format a12 heading 'PROGRAM NAME'
col phase_code_r format b999 heading 'RUNNING|JOBS'
col running_gt_30_min format b999 heading 'RUN|> 30|MIN'
col running_gt_10_min format b999 heading 'RUN|> 10|MIN'
col running_lt_1_min format b999 heading 'RUN|< 1|MIN'
col phase_code_p format b999 heading 'PENDING|JOBS'
col status_code_q format b999 heading 'STANDBY|JOBS'
col status_code_i format b999 heading 'TOTAL|WAIT|JOBS'
col pending_gt_1_min format b999 heading 'WAIT|> 1|MIN'
col pending_gt_5_min format b999 heading 'WAIT|> 5|MIN'
col pending_gt_5_min format b999 heading 'WAIT|> 5|MIN'
col pending_gt_30_min format b999 heading 'WAIT|> 30|MIN'
rem
break on report
compute sum -
of phase_code_r running_gt_30_min running_gt_10_min running_lt_1_min phase_code_p -
status_code_q status_code_i pending_gt_1_min pending_gt_5_min pending_gt_30_min -
on report
rem
select nvl( c.request_class_name, 'STANDARD' ) request_class_name,
count( decode( phase_code, 'R', 'R' ) ) phase_code_r,
count( decode( phase_code, 'R',
decode( 1/1440, greatest( 1/1440, sysdate - r.actual_start_date ),
'R' ) ) ) running_lt_1_min,
count( decode( phase_code, 'R',
decode( 10/1440, least( 10/1440, sysdate - r.actual_start_date ),
'R' ) ) ) running_gt_10_min,
count( decode( phase_code, 'R',
decode( 30/1440, least( 30/1440, sysdate - r.actual_start_date ),
'R' ) ) ) running_gt_30_min,
count( decode( phase_code, 'P', 'P' ) ) phase_code_p,
count( decode( status_code, 'Q', 'Q' ) ) status_code_q,
count( decode( status_code, 'I', 'I' ) ) status_code_i,
count( decode( status_code, 'I',
decode( 1/1440, greatest( 1/1440, sysdate - greatest( r.requested_start_date, r.request_date ) ),
null, 'I' ) ) ) pending_gt_1_min,
count( decode( status_code, 'I',
decode( 5/1440, greatest( 5/1440, sysdate - greatest( r.requested_start_date, r.request_date ) ),
null, 'I' ) ) ) pending_gt_5_min,
count( decode( status_code, 'I',
decode( 30/1440, greatest( 30/1440, sysdate - greatest( r.requested_start_date, r.request_date ) ),
null, 'I' ) ) ) pending_gt_30_min
from applsys.fnd_concurrent_requests r,
applsys.fnd_concurrent_request_class c
where r.request_class_application_id = c.application_id(+)
and r.concurrent_request_class_id = c.request_class_id(+)
and phase_code in ( 'P', 'R' )
and status_code not in ( 'W' )
and r.hold_flag = 'N'
and greatest( r.requested_start_date, r.request_date ) <= sysdate
group by c.request_class_name
order by 1;
