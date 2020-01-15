set lines 180
select o.level_value,u.user_name,u.description
from applsys.fnd_profile_options v, applsys.fnd_profile_option_values o,applsys.fnd_user u
where v.application_id=o.application_id
and v.profile_option_id=o.profile_option_id
and v.profile_option_name='PRINTER'
AND O.profile_option_value like '%ISLPEF1%'
and o.level_value=u.user_id;
