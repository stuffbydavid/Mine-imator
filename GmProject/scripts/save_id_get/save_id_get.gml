/// save_id_get(object)
/// @arg object
/// @desc Safe way to get the save ID of an object. "" if invalid.

function save_id_get(obj)
{
	if (obj = "")
		return ""
	
	if (obj = mc_res.save_id || (is_real(obj) && obj < 0)) // Default asset or technical ID?
		return obj
	
	if (instance_exists(obj))
		return obj.save_id
	
	return ""
}
