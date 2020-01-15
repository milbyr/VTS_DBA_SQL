select concurrent_queue_name
 from applsys.fnd_concurrent_queues
where CONCURRENT_QUEUE_ID =
  (select concurrent_queue_id
    from applsys.fnd_concurrent_processes
    where CONCURRENT_PROCESS_ID = (
      select controlling_manager
      from applsys.fnd_concurrent_requests
      where request_id = &1
    )
  )
;
