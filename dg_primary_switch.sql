
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;



-- To transition the current primary database to a physical 
-- standby database role, use the following SQL statement 
-- on the primary database:
--
-- Login ukepu102 as oraprod

ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY;
SHUTDOWN IMMEDIATE;
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;


-- Carry out the following on the Standby instance on ukepu106
-- Login ukepu102 as oraprod

SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
SQL> SHUTDOWN;
SQL> STARTUP;




