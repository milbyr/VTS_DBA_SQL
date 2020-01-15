Primary

SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE; 

To transition the current primary database to a physical standby database role, use the following SQL statement on the primary database:
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY;

Shut down the former primary instance and restart it without mounting the database:
SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP NOMOUNT; 


Mount the database as a physical standby database:
SQL> ALTER DATABASE MOUNT STANDBY DATABASE;



Standby

SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE; 
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY; 

Shut down the target standby instance and restart it using the appropriate initialization parameters for the primary role:
SQL> SHUTDOWN;
SQL> STARTUP;

