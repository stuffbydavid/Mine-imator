/// @arg resource

function res_is_ready(res)
{
	if (instance_exists(res) && res.ready)
		return true
		
	return false
}
