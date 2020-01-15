###############################################################################
# show_cr_queues.sql. Written by G.Dickson 30/10/2007.                        #
#                                                                             #
# Will display the concurrent queues without running the front end 	#
# application which is slow and not in any useful    #
# order.                                                                      #
#                                                                             #
# Version History                                                             #
###############################################################################

Set lines 132
col USER_CONCURRENT_QUEUE_NAME format A47
col CONCURRENT_QUEUE_NAME format A47
col NODE format A6
col MAX format 999
col TARGET format 999999
col RUN format 999

Select CONCURRENT_QUEUE_NAME, USER_CONCURRENT_QUEUE_NAME
, NODE_NAME NODE, MAX_PROCESSES MAX
, TARGET_PROCESSES TARGET, RUNNING_PROCESSES RUN
from apps.FND_CONCURRENT_QUEUES_VL
where MAX_PROCESSES > 0
order by MAX_PROCESSES, USER_CONCURRENT_QUEUE_NAME ;

