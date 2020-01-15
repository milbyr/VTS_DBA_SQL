set lines 140 pages 999 trimout on trimspool on verify off
column stxt format       a10
column mtxt format       a20
column ltxt format       a40
column sint format       999
column mint format    999999
column lint format 999999999
column srea format       999.99
column mrea format    999999.99
column lrea format 999999999.99

column sql_text       like   ltxt heading "SQL|Text"
column sql_dets       like   mtxt heading "SQL_ID|First Load|Last Active"
column executions     like   lint heading "Exec-|utions"
column disk_megs      like   mint heading "Disk|Megs"
column log_megs       like   lint heading "Logical|Megs"
column cpu_secs       like   mint heading "CPU|Seconds"
column ela_secs       like   mint heading "Elap-|sed|Seconds"
column cpu_secs_pexec like   srea heading "CPU|Seconds|Per|Exec"
column ela_secs_pexec like   mrea heading "Elap-|sed|Seconds|Per|Exec"
column sql_rank       like   sint heading "Rank"
column perc           like   sint heading "Perc|of|Tot|al"

compute sum of perc on report
break on report

PROMPT //
PROMPT // Order by options
PROMPT //
PROMPT //  1: Executions
PROMPT //  2: Disk I/O
PROMPT //  3: Logical I/O
PROMPT //  4: CPU seconds
PROMPT //  5: Elapsed seconds
PROMPT //  6: CPU seconds/exec
PROMPT //  7: Elapsed seconds/exec
PROMPT //

ACCEPT v_order_by NUMBER DEFAULT 1 PROMPT 'Enter Number (default 1): '

column calc new_value calc_defn noprint

select decode(&v_order_by,
              1,'executions',
              2,'disk_megs',
              3,'log_megs',
              4,'cpu_secs',
              5,'ela_secs',
              6,'cpu_secs_pexec',
              7,'ela_secs_pexec',
              'executions') calc
from   dual;


select t1.*, 
       &calc_defn/(sum(t1.&calc_defn) over ())*100 as perc
from  (select rank () over (order by &calc_defn desc) as sql_rank, 
              t0.*
       from   (select sql_text                                               as sql_text,
                      sql_id||':'||child_number||chr(10)||
                       first_load_time||chr(10)||
                       to_char(last_active_time,'YYYY-MM-DD/HH24:MI:SS')     as sql_dets,
                      executions                                             as executions,
                      disk_reads*8/1024                                      as disk_megs,
                      buffer_gets*8/1024                                     as log_megs,
                      cpu_time/100000                                        as cpu_secs,
                      elapsed_time/100000                                    as ela_secs,
                      decode(executions,0,0,cpu_time/100000/executions)      as cpu_secs_pexec,
                      decode(executions,0,0,elapsed_time/100000/executions)  as ela_secs_pexec
               from   v$sql) t0) t1
where  t1.sql_rank <= 10
order  by t1.sql_rank asc, &calc_defn desc;
