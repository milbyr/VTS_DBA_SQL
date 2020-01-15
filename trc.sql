select c.value || '/' || lower(d.value) || '_ora_' ||
       a.spid || '.trc' "TRACE FILE"
from v$process a, v$session b, v$parameter c, v$parameter d
where a.addr = b.paddr
  and b.audsid = userenv('sessionid')
  and c.name   = 'user_dump_dest'
  and d.name   = 'db_name';


--       to_char(a.spid, 'fm00000') || '.trc' "TRACE FILE"
