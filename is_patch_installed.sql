set lines 200
col ORIG_BUG_NUMBER for a10
col REASON_NOT_APPLIED for a10
col APPLICATION_SHORT_NAME for a5
col FAILURE_COMMENTS for a10
select * from ad_patch_run_bugs where orig_bug_number='&patch';

