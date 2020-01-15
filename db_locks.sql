REM ###################################################
REM ## db_locks..sql Version 1.0                     ##
REM ## Robert Milby 25-Sep-2007                      ##
REM ## Display current database locks over the RAC   ##
REM ## Run from SQL>@db_locks                        ##
REM ###################################################
REM ## Version changes below :                       ##
REM ## Date         Name          Change Description ##
REM ###################################################

col SID FORMAT A10
col sess form a20
col module form a26
col action form a40
col holder NOPRINT

set lines 180
set pages 80

break on holder skip 1

WITH sid_info AS (
 SELECT DECODE(request,0,'Holder: ','    Waiter: ')||sid  sess,
        sid, id1, id2, lmode, request, type, DECODE(request,0,'Holder: ','    Waiter: ') holder
  FROM V$LOCK
  WHERE (id1, id2, type) IN
        (SELECT id1, id2, type FROM GV$LOCK
  WHERE request>0)
  ORDER BY id1, request)
select      Sess,
            id1, id2, lmode, request, sid_info.type,
            to_char(logon_time, 'dd-mon-yy hh24:mi:ss') day
          , module
          , action
          , holder
     from v$session, sid_info
     where v$session.sid = sid_info.sid;
--     and v$session.inst_id = sid_info.inst_id;

