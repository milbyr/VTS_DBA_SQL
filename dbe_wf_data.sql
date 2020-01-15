/*$Header: bde_wf_data.sql 11.5.107/16/01 */
set term off;

/*
 TITLE bde_wf_data.sql
 
 DESCRIPTION

 Script to profile the workflow runtime data in regards to eligibility for purging.  
 This script should be used to determine the manner in which the workflow runtime data is 
 distributed, especially by item type.  It also identifies item_type/item_key combinations 
 that have an exhorbitant number of rows in the wf_item_activity_statuses (_h) table(s), indicating
 that there may have been a looping problem within a process flow.

 Since this script runs against large tables and FULL TABLE SCANS are necessary, it may run 
 for a long time.  Please run this script during off hours or against a TEST instance which 
 closely reflects production. 

 EXECUTION

 Run the script from a SQL*Plus session logged in as the APPS user.  The script can accept an
 ITEM_TYPE or can be run against all ITEM_TYPES by hitting enter when prompted.  The output 
 spools to a file called bde_wf_data.lst. 

 NOTES

 1. The output can be FTP'd to a PC and then loaded into wordpad.  
    Go to Page Setup and select Landscape as the Paper Size.
    Modify all 4 Margins to 0.5".
    Select all your document (Ctrl-A) and use Format Font to change the current
    font to Courier or New Courier 8.  
    With all your document selected (Ctrl-A) use Format Parragraph to set both
    Before and After Spacing to 0.  It comes with null causing a one line 
    spacing between lines.

 DISCLAIMER 
 
 This script is provided for educational purposes only.  It is not supported 
 by Oracle World Wide Technical Support.  The script has been tested and 
 appears to works as intended.  However, you should always test any script 
 before relying on it. 
 
 Proofread this script prior to running it!  Due to differences in the way text 
 editors, email packages and operating systems handle text formatting (spaces, 
 tabs and carriage returns), this script may not be in an executable state 
 when you first receive it.  Check over the script to ensure that errors of 
 this type are corrected. 

 This script can be given to customers.  Do not remove disclaimer paragraph.

 HISTORY 
 
 16-JUL-01 Created                                                   rnmercer 

*/

set term on;
set linesize 105;
/*
 The STATEMENT column is the sql command used to purge the data associated with the row.  
 A COMMIT is necessary after executing these statements in order to have them reflected 
 permanently in the database.  

 !!!!!!!IMPORTANT!!!!!!!
 Please use these statements only upon the recommendation of SUPPORT and your onsite DBA
 and System Administrator.  If there is a Workflow Administrator, please inform them of 
 the desire to run these WF_PURGE commands.  There is no inherent backup to restore from 
 the purging API's.  The API's are designed to purge only the data which is old and 
 inactive.

 Please read Notes 144806.1 and 132254.1 for more information on WF_PURGE.

*/

set echo off;
set verify off;
set linesize 135;

spool bde_wf_data;

column ITEM_KEY     format    a12;
column HISTORY      format    a07;
column STATEMENT    format    a51;
column ITEM_TYPE    format    a09;
column DISPLAY_NAME format    a80;
column AVG_LIFE     format    9999.99;
column MIN_LIFE     format    9999.99;
column MAX_LIFE     format    9999.99;
column DEV          format    9999.99;
column P_DAYS       format    99999;
column END_DATE     format    a10;
column BEGIN_DATE   format    a10;
column DESCRIPTION  format    a28;


accept item_type_selected prompt 'Please enter ITEM_TYPE (default %): '

prompt Workflow Item Types Defined in DB

select wit.NAME                    ITEM_TYPE, 
       wit.persistence_type        P_TYPE,  
       WIT.PERSISTENCE_DAYS        P_DAYS,
       wtl.DISPLAY_NAME            DISPLAY_NAME
     from wf_item_types    wit,
          wf_item_types_tl wtl
     where wtl.name = wit.name
     order by 1;

BREAK ON REPORT;
COMPUTE SUM OF COUNT ON REPORT;

prompt Closed Workflow Items

select wi.item_type                  ITEM_TYPE, 
       wit.persistence_type          P_TYPE,  
       WIT.PERSISTENCE_DAYS          P_DAYS,
       count(*)                      COUNT, 
       avg(end_date - begin_date)    AVG_LIFE,
       STDDEV(end_date - begin_date) DEV,
       MIN(end_date - begin_date)    MIN_LIFE,
       MAX(end_date - begin_date)    MAX_LIFE,
       ('exec WF_PURGE.ITEMS('''||WI.ITEM_TYPE||''',NULL,SYSDATE,FALSE);') STATEMENT
     from wf_items wi,
          wf_item_types wit
     where wi.end_date is not null
       and wit.name = wi.item_type
     group by item_type, 
              wit.persistence_type, 
              WIT.PERSISTENCE_DAYS
     order by 2,4,1;

column STATEMENT format a75;

prompt Open and Closed Workflow Items

select wi.item_type                               ITEM_TYPE, 
       wit.persistence_type                       P_TYPE,  
       WIT.PERSISTENCE_DAYS                       P_DAYS,
       count(*)                                   COUNT,
       avg(nvl(end_date,sysdate) - begin_date)    AVG_LIFE,
       STDDEV(nvl(end_date,sysdate) - begin_date) DEV,
       MIN(nvl(end_date,sysdate) - begin_date)    MIN_LIFE,
       MAX(nvl(end_date,sysdate) - begin_date)    MAX_LIFE
     from wf_items wi,
          wf_item_types wit,
          wf_item_types_tl wtl
     where wit.name = wi.item_type
       and wtl.name = wit.name
     group by wi.item_type, 
              wit.persistence_type, 
              WIT.PERSISTENCE_DAYS,
              wtl.DISPLAY_NAME            
     order by 2,4,1;

prompt Closed Activity Statuses 

select sta.item_type              ITEM_TYPE, 
       count(*)                   COUNT,
       ('exec WF_PURGE.ITEMS('''||STA.ITEM_TYPE||''',NULL,SYSDATE,FALSE);') STATEMENT
from wf_item_activity_statuses sta,
     wf_items wfi
where sta.item_type = wfi.item_type
  and sta.item_key = wfi.item_key
  and wfi.end_date is not null
group by sta.item_type
order by 2,1;

prompt Open and Closed Activity Statuses

select sta.item_type          ITEM_TYPE, 
       count(*)               COUNT
from wf_item_activity_statuses sta,
     wf_items wfi
where sta.item_type = wfi.item_type
  and sta.item_key  = wfi.item_key
group by sta.item_type
order by 2,1;

prompt Large Activity Status Item Keys
column STATEMENT format a51;
select sta.item_type, 
       sta.item_key, 
       count(*),
       wfi.begin_date,
       wfi.end_date, 
       decode(wfi.end_date, NULL, 'Run $FND_TOP/sql/WFSTAT.SQL to pursue closing item',
          ('exec WF_PURGE.ITEMS('''||STA.ITEM_TYPE||''','''||STA.ITEM_KEY||''',SYSDATE,FALSE);')
             ) STATEMENT
from wf_item_activity_statuses sta,
     wf_items wfi
where sta.item_type = wfi.item_type
  and sta.item_key  = wfi.item_key
group by sta.item_type, 
         sta.item_key, 
         wfi.begin_date,
         wfi.end_date
having count(*) > 100
order by 2,1,3;


prompt Closed Activity History Statuses 
column STATEMENT format a75;
select sta.item_type         ITEM_TYPE, 
       count(*)              COUNT,
       ('exec WF_PURGE.ITEMS('''||STA.ITEM_TYPE||''',NULL,SYSDATE,FALSE);') STATEMENT
from wf_item_activity_statuses_h sta,
     wf_items wfi
where sta.item_type = wfi.item_type
  and sta.item_key  = wfi.item_key
  and wfi.end_date  is not null
group by sta.item_type
order by 2,1;

prompt Large activity History Status Item Keys
column STATEMENT format a51;
select sta.item_type       ITEM_TYPE, 
       sta.item_key        ITEM_KEY, 
       count(*)            COUNT,
       wfi.begin_date      BEGIN_DATE,
       wfi.end_date        END_DATE, 
       wfi.user_key        DESCRIPTION,
       decode(wfi.end_date, NULL, 'Run $FND_TOP/sql/WFSTAT.SQL to pursue closing item',
          ('exec WF_PURGE.ITEMS('''||STA.ITEM_TYPE||''','''||STA.ITEM_KEY||''',SYSDATE,FALSE);')
             )             STATEMENT
from wf_item_activity_statuses_h sta,
     wf_items wfi
where sta.item_type = wfi.item_type
  and sta.item_key  = wfi.item_key
group by sta.item_type, 
      sta.item_key,
      wfi.USER_KEY,
      wfi.begin_date, 
      wfi.end_date
having count(*) > 100
order by 2,1,3;

prompt Notification Totals 
column STATEMENT format a75;
    select WN.MESSAGE_TYPE     ITEM_TYPE, 
           count(*)            COUNT
     from WF_NOTIFICATIONS WN
    group by WN.MESSAGE_TYPE
    order by 2;

prompt Unreferenced Notifications - Purge using WF_PURGE.NOTIFICATIONS

    select WN.MESSAGE_TYPE     ITEM_TYPE, 
           count(*)            COUNT,
           'N'                 HISTORY,
          ('exec WF_PURGE.NOTIFICATIONS('''||WN.MESSAGE_TYPE||''',SYSDATE,FALSE);') STATEMENT
     from WF_NOTIFICATIONS WN
     where not exists
       (select NULL
       from WF_ITEM_ACTIVITY_STATUSES WIAS
       where WIAS.NOTIFICATION_ID = WN.GROUP_ID)
     group by WN.MESSAGE_TYPE
    union all
    select WN.MESSAGE_TYPE     ITEM_TYPE, 
           count(*)            COUNT,
           'Y'                 HISTORY,
          ('exec WF_PURGE.NOTIFICATIONS('''||WN.MESSAGE_TYPE||''',SYSDATE,FALSE);') STATEMENT
     from WF_NOTIFICATIONS WN
     where not exists
       (select NULL
       from WF_ITEM_ACTIVITY_STATUSES_H WIAS
       where WIAS.NOTIFICATION_ID = WN.GROUP_ID)
     and exists
     (select null
     from WF_ITEM_TYPES WIT
     where WN.END_DATE+nvl(WIT.PERSISTENCE_DAYS,0)<=sysdate
     and WN.MESSAGE_TYPE = WIT.NAME
     and WIT.PERSISTENCE_TYPE = 'TEMP')
    group by WN.MESSAGE_TYPE
    order by 2;

prompt Notifications linked to closed Items - Purge using WF_PURGE.ITEM_NOTIFICATIONS

  select WI.ITEM_TYPE             ITEM_TYPE,
         count(1)                 COUNT,
         'N'                      HISTORY,
         ('exec WF_PURGE.ITEM_NOTIFICATIONS('''||WI.ITEM_TYPE||''',NULL,SYSDATE,FALSE);') STATEMENT
  from WF_ITEM_ACTIVITY_STATUSES WIAS, 
       WF_ITEMS WI
  where WIAS.NOTIFICATION_ID is not null
    and WI.ITEM_TYPE = WIAS.ITEM_TYPE
    and WI.ITEM_KEY = WIAS.ITEM_KEY
    and WI.END_DATE is not null
    and exists
    (select null
     from WF_ITEM_TYPES WIT
     where WIAS.END_DATE+nvl(WIT.PERSISTENCE_DAYS,0)<=(sysdate-300)
       and WIAS.ITEM_TYPE = WIT.NAME
       and WIT.PERSISTENCE_TYPE = 'TEMP')
  group by WI.ITEM_TYPE
  union 
  select WI.ITEM_TYPE             ITEM_TYPE,
         count(1)                 COUNT,
         'Y'                      HISTORY,
         ('exec WF_PURGE.ITEM_NOTIFICATIONS('''||WI.ITEM_TYPE||''',NULL,SYSDATE,FALSE);') STATEMENT
  from WF_ITEM_ACTIVITY_STATUSES_H WIAS, 
       WF_ITEMS WI
  where WIAS.NOTIFICATION_ID is not null
    and WI.ITEM_TYPE = WIAS.ITEM_TYPE
    and WI.ITEM_KEY = WIAS.ITEM_KEY
    and WI.END_DATE is not null
    and exists
    (select null
     from WF_ITEM_TYPES WIT
     where WIAS.END_DATE+nvl(WIT.PERSISTENCE_DAYS,0)<=(sysdate-300)
       and WIAS.ITEM_TYPE = WIT.NAME
       and WIT.PERSISTENCE_TYPE = 'TEMP')
  group by WI.ITEM_TYPE
  order by 2;

PROMPT If you run any Purge API that deletes 10% of the data or more Gather Stats using:
PROMPT ITEMS
PROMPT =====
SELECT 'EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname=>''APPLSYS'',tabname=>''WF_ITEM_ACTIVITY_STATUSES'');' GATHER_STATEMENT from dual
UNION ALL                                                                                                                      
SELECT 'EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'||'''APPLSYS'''||
         ',tabname=>'||'''WF_ITEM_ACTIVITY_STATUSES'''||
         ',percent=>10'||
         ',granularity=>'||DECODE((SELECT PARTITIONED FROM ALL_TABLES AT 
                                 WHERE  AT.OWNER      = 'APPLSYS' 
                                 AND    AT.TABLE_NAME = 'WF_ITEM_ACTIVITY_STATUSES'),
                                'YES','''PARTITION''','''DEFAULT''')||');' GATHER_STATEMENT
FROM DUAL
UNION ALL
SELECT 'EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname=>''APPLSYS'',tabname=>''WF_ITEM_ACTIVITY_STATUSES_H'');' GATHER_STATEMENT from dual
UNION ALL                                                                                                                      
SELECT 'EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'||'''APPLSYS'''||
         ',tabname=>'||'''WF_ITEM_ACTIVITY_STATUSES_H'''||
         ',percent=>10'||
         ',granularity=>'||DECODE((SELECT PARTITIONED FROM ALL_TABLES AT 
                                 WHERE  AT.OWNER      = 'APPLSYS' 
                                 AND    AT.TABLE_NAME = 'WF_ITEM_ACTIVITY_STATUSES_H'),
                                'YES','''PARTITION''','''DEFAULT''')||');' GATHER_STATEMENT
FROM DUAL
UNION ALL
SELECT 'EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname=>''APPLSYS'',tabname=>''WF_ITEM_ATTRIBUTE_VALUES'');' GATHER_STATEMENT from dual
UNION ALL                                                                                                                      
SELECT 'EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'||'''APPLSYS'''||
         ',tabname=>'||'''WF_ITEM_ATTRIBUTE_VALUES'''||
         ',percent=>10'||
         ',granularity=>'||DECODE((SELECT PARTITIONED FROM ALL_TABLES AT 
                                 WHERE  AT.OWNER      = 'APPLSYS' 
                                 AND    AT.TABLE_NAME = 'WF_ITEM_ATTRIBUTE_VALUES'),
                                'YES','''PARTITION''','''DEFAULT''')||');' GATHER_STATEMENT
FROM DUAL
UNION ALL
SELECT 'EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname=>''APPLSYS'',tabname=>''WF_ITEMS'');' GATHER_STATEMENT from dual
UNION ALL                                                                                                                      
SELECT 'EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'||'''APPLSYS'''||
         ',tabname=>'||'''WF_ITEMS'''||
         ',percent=>10'||
         ',granularity=>'||DECODE((SELECT PARTITIONED FROM ALL_TABLES AT 
                                 WHERE  AT.OWNER      = 'APPLSYS' 
                                 AND    AT.TABLE_NAME = 'WF_ITEMS'),
                                'YES','''PARTITION''','''DEFAULT''')||');' GATHER_STATEMENT
FROM DUAL
UNION ALL
SELECT 'EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname=>''APPLSYS'',tabname=>''WF_NOTIFICATIONS'');' GATHER_STATEMENT from dual
UNION ALL
SELECT 'EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'||'''APPLSYS'''||
         ',tabname=>'||'''WF_NOTIFICATIONS'''||
         ',percent=>10'||
         ',granularity=>'||DECODE((SELECT PARTITIONED FROM ALL_TABLES AT 
                                 WHERE  AT.OWNER      = 'APPLSYS' 
                                 AND    AT.TABLE_NAME = 'WF_NOTIFICATIONS'),
                                'YES','''PARTITION''','''DEFAULT''')||');' GATHER_STATEMENT
FROM DUAL
UNION ALL
SELECT 'EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname=>''APPLSYS'',tabname=>''WF_NOTIFICATION_ATTRIBUTES'');' GATHER_STATEMENT from dual
UNION ALL
SELECT 'EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'||'''APPLSYS'''||
         ',tabname=>'||'''WF_NOTIFICATION_ATTRIBUTES'''||
         ',percent=>10'||
         ',granularity=>'||DECODE((SELECT PARTITIONED FROM ALL_TABLES AT 
                                 WHERE  AT.OWNER      = 'APPLSYS' 
                                 AND    AT.TABLE_NAME = 'WF_NOTIFICATION_ATTRIBUTES'),
                                'YES','''PARTITION''','''DEFAULT''')||');' GATHER_STATEMENT
FROM DUAL;

PROMPT NOTIFICATIONS or ITEM_NOTIFICATIONS
PROMPT ===================================
SELECT 'EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname=>''APPLSYS'',tabname=>''WF_NOTIFICATIONS'');' GATHER_STATEMENT from dual
UNION ALL
SELECT 'EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'||'''APPLSYS'''||
         ',tabname=>'||'''WF_NOTIFICATIONS'''||
         ',percent=>10'||
         ',granularity=>'||DECODE((SELECT PARTITIONED FROM ALL_TABLES AT 
                                 WHERE  AT.OWNER      = 'APPLSYS' 
                                 AND    AT.TABLE_NAME = 'WF_NOTIFICATIONS'),
                                'YES','''PARTITION''','''DEFAULT''')||');' GATHER_STATEMENT
FROM DUAL
UNION ALL
SELECT 'EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname=>''APPLSYS'',tabname=>''WF_NOTIFICATION_ATTRIBUTES'');' GATHER_STATEMENT from dual
UNION ALL
SELECT 'EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'||'''APPLSYS'''||
         ',tabname=>'||'''WF_NOTIFICATION_ATTRIBUTES'''||
         ',percent=>10'||
         ',granularity=>'||DECODE((SELECT PARTITIONED FROM ALL_TABLES AT 
                                 WHERE  AT.OWNER      = 'APPLSYS' 
                                 AND    AT.TABLE_NAME = 'WF_NOTIFICATION_ATTRIBUTES'),
                                'YES','''PARTITION''','''DEFAULT''')||');' GATHER_STATEMENT
FROM DUAL;

spool off;

CLEAR BREAKS;
CLEAR COMPUTES;
CLEAR COLUMNS;
exit

