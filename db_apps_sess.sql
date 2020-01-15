SET VER OFF

ALTER SESSION SET CURRENT_SCHEMA=APPS
;

PROMPT
PROMPT shows information about APPS user (no concurent sessions!!) ....
PROMPT

undefine apps_user;
accept apps_user char prompt 'Input starting letters of APPS username : ';

col sid_serial for a13;
col user_name for A10;
col module for a15;
col Responsibility for a15;
col function for a15;
col F_Type for a10;
col app_pid for a6;
col db_pid for a6;

break on USER_NAME on db_pid on app_pid on sid_serial

select * from (
select
usr.user_name user_name
,v.spid db_pid
,ses.process app_pid
,ses.sid||','||ses.serial# sid_serial
-- ,i.first_connect Connection
,ses.module
,rsp.responsibility_name Responsibility
,fuc.function_name Function
,i.function_type F_Type
,to_char(i.last_connect,'dd.mm hh24:mi') F_Start
from icx_sessions i
,fnd_logins l
,fnd_appl_sessions a
,fnd_user usr
,fnd_responsibility_tl rsp
,fnd_form_functions fuc
,gv$process v
,gv$session ses
where i.disabled_flag = 'N'
and i.login_id = l.login_id
and l.end_time is null
and i.user_id = usr.user_id
and l.login_id = a.login_id
and a.audsid = ses.audsid
and l.pid = v.pid
and l.serial# = v.serial#
and i.responsibility_application_id = rsp.application_id(+)
and i.responsibility_id = rsp.responsibility_id(+)
and i.function_id = fuc.function_id(+)
and i.responsibility_id not in (select t1.responsibility_id
from fnd_login_responsibilities t1
where t1.login_id = l.login_id
)
and usr.user_name like '&apps_user%'
union
select
usr.user_name
,v.spid
,ses.process
,ses.sid||','||ses.serial# sid_serial
-- ,l.start_time
,ses.module
,rsp.responsibility_name
,null
,null
,null form_start_time
from fnd_logins l
,fnd_login_responsibilities r
,fnd_user usr
,fnd_responsibility_tl rsp
,gv$process v
,gv$session ses
where l.end_time is null
and l.user_id = usr.user_id
and l.pid = v.pid
and l.serial# = v.serial#
and v.addr = ses.paddr
and l.login_id = r.login_id(+)
and r.end_time is null
and r.responsibility_id = rsp.responsibility_id(+)
and r.resp_appl_id = rsp.application_id(+)
and r.audsid = ses.audsid
and usr.user_name like '&apps_user%'
union
select
usr.user_name
,v.spid
,ses.process
,ses.sid||','||ses.serial# sid_serial
-- ,l.start_time
,ses.module
,null
,frm.user_form_name
,ff.type
,to_char(f.start_time,'dd.mm hh24:mi')
from fnd_logins l
,fnd_login_resp_forms f
,fnd_user usr
,fnd_form_tl frm
,fnd_form_functions ff
,gv$process v
,gv$session ses
where l.end_time is null
and l.user_id = usr.user_id
and l.pid = v.pid
and l.serial# = v.serial#
and v.addr = ses.paddr
and l.login_id = f.login_id(+)
and f.end_time is null
and f.form_id = frm.form_id(+)
and f.form_appl_id = frm.application_id(+)
and f.audsid = ses.audsid
and ff.form_id = frm.form_id
and usr.user_name like '&apps_user%'
)
order by user_name, db_pid, app_pid, sid_serial
;
