Task 4.4 - DR Testing Procedure using Flashback Database
In this section we document how the DR configuration can be tested while the primary site is in live operation, and how Flashback Database can be used to quickly restore the DR site to standby operation afterwards.
As a starting point we assume that the primary site is in live operation and the DR site is in standby mode and applying redo.

Step 4.4.1 - Activate and Open the DR Standby Database

On the DR site, cancel managed recovery:
ha2db01:SQL> recover managed standby database cancel;

On the DR site, enable flashback if it has not been enable before:
ha2db01:SQL> alter database flashback on;

On the DR site, create a guaranteed restore point (named .testing _starts. in this example):
ha2db01:SQL> create restore point testing_starts guarantee flashback database;

On primary site, switch the current log and then defer the archive destination:
ha1db01:SQL> alter system archive log current;
ha1db01:SQL> alter system set log_archive_dest_state_2=defer SID=.*.;

On DR site, activate and open the database:
ha2db01:SQL> alter database activate standby database;
ha2db01:SQL> alter database set standby database to maximize performance;
ha2db01:SQL> alter database open;

Step 4.4.2 - Perform Testing

The database is now open and can be used for testing. Any changes that are made to the database will be rolled back afterwards using flashback database. You can start additional databases instances and test the application as you wish.
Transitioning E-Business Suite to the Maximum Availability Architecture with Minimal Downtime Page 52 Maximum Availability Architecture
Note that the DR site will be getting behind on redo application during the testing period and so make sure that you do not get too far behind.

Step 4.4.3 - Flashback the Database and Resume Standby Operation

On the DR site, shutdown all but one database instance. In this example, only the instance on ha2db01 remains.
On the DR site, flashback and start managed recovery:
ha2db01:SQL> startup mount force;
ha2db01:SQL> flashback database to restore point testing_starts;
ha2db01:SQL> drop restore point testing_starts;
ha2db01:SQL> alter database convert to physical standby;
ha2db01:SQL> startup mount force;
ha2db01:SQL> alter database recover managed standby database using current logfile disconnect;

On the primary site, enable the archive destination:
ha1db01:SQL> alter system set log_archive_dest_state_2=enable SID=.*.;
