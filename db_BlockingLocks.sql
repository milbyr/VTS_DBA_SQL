declare

 cursor c_blocking_locks
 is
  select
   w.session_id  waiting_session,
   h.session_id  holding_session,
   w.lock_type,
   (select module || ' :: ' || action from v$session where sid=h.session_id) holding_module_action,
   (select module || ' :: ' || action from v$session where sid=w.session_id) waiting_module_action
  from
   (select /*+ NO_MERGE */ * from dba_locks) w,
   (select /*+ NO_MERGE */ * from dba_locks) h
  where
   (((h.mode_held != 'None') and (h.mode_held != 'Null')
  and ((h.mode_requested = 'None') or (h.mode_requested = 'Null')))
  and
   (((w.mode_held = 'None') or (w.mode_held = 'Null'))
      and ((w.mode_requested != 'None') and (w.mode_requested != 'Null'))))
   and  w.lock_type       =  h.lock_type
   and  w.lock_id1        =  h.lock_id1
   and  w.lock_id2        =  h.lock_id2
   and  w.session_id     !=  h.session_id;

 cursor c_waiting_time(p_sid in number)
 is
 select seconds_in_wait, event
 from v$session_wait
 where sid=p_sid;

 r_blocking_locks c_blocking_locks%ROWTYPE;
 r_waiting_time   c_waiting_time%ROWTYPE;
 l_lock_count     number;

begin

 select count(1)
 into l_lock_count
 from
  (select /*+ NO_MERGE */ * from dba_locks) w,
  (select /*+ NO_MERGE */ * from dba_locks) h
 where
  (((h.mode_held != 'None') and (h.mode_held != 'Null')
 and ((h.mode_requested = 'None') or (h.mode_requested = 'Null')))
 and
  (((w.mode_held = 'None') or (w.mode_held = 'Null'))
     and ((w.mode_requested != 'None') and (w.mode_requested != 'Null'))))
  and  w.lock_type       =  h.lock_type
  and  w.lock_id1        =  h.lock_id1
  and  w.lock_id2        =  h.lock_id2
  and  w.session_id     !=  h.session_id;

 if (l_lock_count > 10)
 then
  dbms_output.put_line('$L_CHECK_ERROR :: Over 10 sessions blocked');
 end if;

 for r_blocking_locks in c_blocking_locks loop
  if (c_blocking_locks%ROWCOUNT = 1)
  then
   dbms_output.put_line('$L_CHECK_WARNING');
   dbms_output.put_line(rpad('Waiting Session',18) ||
                        rpad('Holding Session',18) ||
                        rpad('Lock Type',15) ||
                        rpad('Waiting Module and Action', 60) ||
                        rpad('Holding Module and Action', 60) ||
                        rpad('Seconds in wait', 20) ||
                        rpad('Waiting on ...', 40));
  end if;

  if (c_waiting_time%ISOPEN)
  then
   close c_waiting_time;
  end if;

  open c_waiting_time(r_blocking_locks.waiting_session);
  fetch c_waiting_time into r_waiting_time;

  if (r_waiting_time.seconds_in_wait > 1200)
  then
   dbms_output.put_line('$L_CHECK_ERROR :: Session ' || 
                        r_blocking_locks.waiting_session || 
                        ' blocked for over 20 minutes [ ' ||
                        r_waiting_time.seconds_in_wait || ' seconds ].');
  end if;

  dbms_output.put_line(rpad(r_blocking_locks.waiting_session,18) ||
                       rpad(r_blocking_locks.holding_session,18) ||
                       rpad(r_blocking_locks.lock_type,15) ||
                       rpad(nvl(r_blocking_locks.waiting_module_action,'.'), 60) ||
                       rpad(nvl(r_blocking_locks.holding_module_action,'.'), 60) ||
                       rpad(r_waiting_time.seconds_in_wait, 20) ||
                       rpad(r_waiting_time.event, 40));

 end loop;
end;
/
