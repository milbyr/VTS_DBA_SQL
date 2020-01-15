col patch_name format a8 heading "Patch|Name"
col instance_name format a10 heading "Instance|Name"
col name format a10 heading "Node Name"
col APPL_TOP format a10
col subdir format a20
col filename format a18
col latest format a20
col driver_file_name format a16 heading "Driver|File|Name"
col action format a10

set lines 150
set pages 1000

Select 
	J.PATCh_NAME, 
	H.APPLICATIONS_SYSTEM_NAME Instance_Name, 
	H.NAME, 
	I.DRIVER_FILE_NAME, 
	D.APP_SHORT_NAME appl_top, 
	D.SUBDIR, 
	D.FILENAME, 
	max(F.VERSION) latest, 
	E.ACTION_CODE action 
from 
	AD_BUGS A, 
	AD_PATCH_RUN_BUGS B, 
	AD_PATCH_RUN_BUG_ACTIONS C, 
	AD_FILES D, 
	AD_PATCH_COMMON_ACTIONS E, 
	AD_FILE_VERSIONS F, 
	AD_PATCH_RUNS G, 
	AD_APPL_TOPS H, 
	AD_PATCH_DRIVERS I, 
	AD_APPLIED_PATCHES J 
where 
	A.BUG_ID = B.BUG_ID and 
	B.PATCH_RUN_BUG_ID = C.PATCH_RUN_BUG_ID and 
	C.FILE_ID = D.FILE_ID and 
	E.COMMON_ACTION_ID = C.COMMON_ACTION_ID and 
	D.FILE_ID = F.FILE_ID and 
	G.APPL_TOP_ID = H.APPL_TOP_ID and 
	G.PATCH_DRIVER_ID = I.PATCH_DRIVER_ID and 
	I.APPLIED_PATCH_ID = J.APPLIED_PATCH_ID and 
	B.PATCH_RUN_ID = G.PATCH_RUN_ID and 
	C.EXECUTED_FLAG = 'Y' and 
	G.PATCH_DRIVER_ID in 
		(select PATCH_DRIVER_ID 
		from AD_PATCH_DRIVERS 
		where APPLIED_PATCH_ID in 
		(select APPLIED_PATCH_ID 
		from AD_APPLIED_PATCHES 
		where PATCH_NAME = '&Patch_Number')) 
GROUP BY 
	J.PATCH_NAME, 
	H.APPLICATIONS_SYSTEM_NAME, 
	H.NAME, 
	I.DRIVER_FILE_NAME, 
	D.APP_SHORT_NAME, 
	D.SUBDIR, 
	D.FILENAME, 
	E.ACTION_CODE;


