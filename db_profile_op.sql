set pagesize 10000
COLUMN profileName  format a30 heading 'Name'
COLUMN profileLevel format a10 heading 'Level'
COLUMN profileValue format a30 heading 'Value'
BREAK ON profileName

SELECT ot.user_profile_option_name profileName,
       DECODE(v.level_id,10001, 'Site'
                        ,10002, 'App:'
                        ,10003, 'Responsiblity'
                        ,10004, 'User') ||
       DECODE(v.level_id,
                       10001, '',
                       10002, ' ' || a.application_name,
                       10003, ' ' || r.responsibility_name,
                       10004, ' ' || u.user_name) profileLevel,
       v.profile_option_value profileValue
FROM fnd_profile_option_values v,
     fnd_profile_options o,
     fnd_profile_options_vl ot,
     fnd_application_tl a,
     fnd_responsibility_vl r,
     fnd_user u
WHERE  upper(o.profile_option_name) like upper('BNE%')
  AND  v.LEVEL_VALUE =
           decode(level_id, 10001, 0
                          , 10002, 800
                          , 10003, 0
                          , 10004, 0)
  AND v.profile_option_id = o.profile_option_id
  AND v.application_id = o.application_id
  AND a.application_id (+) = v.level_value
  AND r.responsibility_id (+) = v.level_value
  AND u.user_id (+) = v.level_value
  AND ot.profile_option_name = o.profile_option_name
  AND sysdate between nvl(o.start_date_active, sysdate) AND
      nvl(o.end_date_active,sysdate)
  AND v.profile_option_value IS NOT NULL
ORDER BY ot.user_profile_option_name, v.level_id
/


