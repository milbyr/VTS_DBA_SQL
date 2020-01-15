
set lines 155 pages 999 verify off trimout on trimspool on tab off feedback off
col day for a10

prompt ;
prompt ==============================;
prompt = Log switch frequency by hour;
prompt ==============================;
  select to_char(first_time,'YYYY-MM-DD') day,
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0)),'999') "00",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0)),'999') "01",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0)),'999') "02",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0)),'999') "03",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0)),'999') "04",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0)),'999') "05",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0)),'999') "06",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0)),'999') "07",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0)),'999') "08",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0)),'999') "09",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0)),'999') "10",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0)),'999') "11",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0)),'999') "12",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0)),'999') "13",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0)),'999') "14",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0)),'999') "15",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0)),'999') "16",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0)),'999') "17",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0)),'999') "18",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0)),'999') "19",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0)),'999') "20",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0)),'999') "21",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0)),'999') "22",
         to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0)),'999') "23"
  from v$log_history
  where first_time > trunc(sysdate) - 32
  group by to_char(first_time,'YYYY-MM-DD')
  order by to_char(first_time,'YYYY-MM-DD');

prompt ;
prompt ==============================;
prompt = Log switch Megabytes by hour;
prompt ==============================;

  with raw_data
  as   (select round(blocks*block_size/1024/1024,0) megs, completion_time
        from   v$archived_log
        where  dest_id = (select dest_id from V$ARCHIVE_DEST where status = 'VALID' and target = 'PRIMARY' and rownum < 2)
        and    first_time > trunc(sysdate) - 32)
  select to_char(completion_time,'YYYY-MM-DD') day,
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'00',megs,0)),'9999') "00",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'01',megs,0)),'9999') "01",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'02',megs,0)),'9999') "02",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'03',megs,0)),'9999') "03",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'04',megs,0)),'9999') "04",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'05',megs,0)),'9999') "05",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'06',megs,0)),'9999') "06",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'07',megs,0)),'9999') "07",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'08',megs,0)),'9999') "08",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'09',megs,0)),'9999') "09",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'10',megs,0)),'9999') "10",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'11',megs,0)),'9999') "11",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'12',megs,0)),'9999') "12",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'13',megs,0)),'9999') "13",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'14',megs,0)),'9999') "14",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'15',megs,0)),'9999') "15",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'16',megs,0)),'9999') "16",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'17',megs,0)),'9999') "17",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'18',megs,0)),'9999') "18",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'19',megs,0)),'9999') "19",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'20',megs,0)),'9999') "20",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'21',megs,0)),'9999') "21",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'22',megs,0)),'9999') "22",
         to_char(sum(decode(substr(to_char(completion_time,'HH24'),1,2),'23',megs,0)),'9999') "23"
  from  raw_data
  group by to_char(completion_time,'YYYY-MM-DD')
  order by to_char(completion_time,'YYYY-MM-DD');

