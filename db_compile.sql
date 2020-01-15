set head off pages 0 lines 132

select 'alter '||
decode(object_type,'PACKAGE BODY', 'package',object_type) ||
' '||owner||'.'||
 object_name||
 decode(object_type,'PACKAGE BODY', ' compile body;',' compile;')
 from dba_objects
 where status = 'INVALID';

