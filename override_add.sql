select fscpv.parameter_value
from fnd_svc_comp_params_tl fscpt, fnd_svc_comp_param_vals fscpv
where fscpt.display_name = 'Test Address' and fscpt.parameter_id = fscpv.parameter_id;
