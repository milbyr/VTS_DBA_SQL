break on index_name skip 1 on report

set pages 100
set lines 130
col index_name form a30
col column_name form a40
col column_position  head pos form 99

select index_name, column_name, column_position
from dba_ind_columns
where table_name = '&1'
order by 1,3
/

