Column host format a6;
Column username format a10;
Column os_user format a8;
Column program format a30;
Column tsname format a12;
 
select
   S.gmachine host,
   S.gusername username,
   S.gserver,
   S.gosuser os_user,
   S.gprogram program,
   DF.tablespace_name ts_name,
   row_wait_file# file_nbr,
   row_wait_block# block_nbr,
   E.owner,
   E.segment_name,
   E.segment_type
from 
   dba_data_files DF,
   v$session      S, 
   dba_extents    E 
where S.grow_wait_file# = DF.file_id
  and E.file_id = row_wait_file#
  and S.row_wait_block# between E.block_id and E.block_id + E.blocks - 1
  and S.row_wait_file# <> 0
  and S.type='USER';
  
