set serveroutput on 

prompt Notification Subsystem Queue Info
prompt This requires package WF_QUEUE to be valid
prompt ______________________________________________________________________________

declare
  l_readyc          NUMBER;
  l_waitc           NUMBER;
  l_processedc      NUMBER;
  l_expiredc        NUMBER;
  l_undeliverablec  NUMBER;
  l_errorc          NUMBER;
begin

    WF_QUEUE.getCntMsgSt
        (p_agent        => 'WF_DEFERRED',
         p_ready        => l_readyc,
         p_wait         => l_waitc,
         p_processed    => l_processedc,
         p_expired      => l_expiredc,
         p_undeliverable => l_undeliverablec,
         p_error        => l_errorc);
    dbms_output.put_line('WF_DEFERRED messages ready:' || l_readyc || ', waiting:' || l_waitc || ', expired:'|| l_expiredc || ', undeliverable:' || l_undeliverablec || ', processed:' || l_processedc);

    WF_QUEUE.getCntMsgSt
        (p_agent        => 'WF_NOTIFICATION_OUT',
         p_ready        => l_readyc,
         p_wait         => l_waitc,
         p_processed    => l_processedc,
         p_expired      => l_expiredc,
         p_undeliverable => l_undeliverablec,
         p_error        => l_errorc);
    dbms_output.put_line('WF_NOTIFICATION_OUT messages ready:' || l_readyc || ', waiting:' || l_waitc || ', expired:'|| l_expiredc || ', undeliverable:' || l_undeliverablec || ', processed:' || l_processedc);

    WF_QUEUE.getCntMsgSt
        (p_agent        => 'WF_NOTIFICATION_IN',
         p_ready        => l_readyc,
         p_wait         => l_waitc,
         p_processed    => l_processedc,
         p_expired      => l_expiredc,
         p_undeliverable => l_undeliverablec,
         p_error        => l_errorc);
    dbms_output.put_line('WF_NOTIFICATION_IN messages ready:' || l_readyc || ', waiting:' || l_waitc || ', expired:'|| l_expiredc || ', undeliverable:' || l_undeliverablec || ', processed:' || l_processedc);

    WF_QUEUE.getCntMsgSt
        (p_agent        => 'WF_ERROR',
         p_ready        => l_readyc,
         p_wait         => l_waitc,
         p_processed    => l_processedc,
         p_expired      => l_expiredc,
         p_undeliverable => l_undeliverablec,
         p_error        => l_errorc);
    dbms_output.put_line('WF_ERROR messages ready:' || l_readyc || ', waiting:' || l_waitc || ', expired:'|| l_expiredc || ', undeliverable:' || l_undeliverablec || ', processed:' || l_processedc);

end;
/
