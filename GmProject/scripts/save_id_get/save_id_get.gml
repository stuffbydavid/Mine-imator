/// save_id_get(object)
/// @arg object
/// @desc Safe way to get the save ID of an object. "" if invalid.

function save_id_get(obj)
{
	if (is_string(obj))
	{
		if (obj = "")
			return ""
		
		if (obj = mc_res.save_id) // Default asset
			return obj
	}
	else
	{
		if (is_real(obj) && obj < 0) // Technical ID?
			return obj
		
		if (instance_exists(obj))
			return obj.save_id
	}
	
	return ""
}
