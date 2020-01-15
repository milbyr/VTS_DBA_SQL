set pages 0 lines 500 trims on 
set long 5000000

select dbms_metadata.get_ddl('&OBJECT_TYPE','&OBJECT_NAME','&OWNER') from dual;
