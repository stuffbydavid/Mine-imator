/// save_id_get(object)
/// @arg object
/// @desc Safe way to get the save ID of an object. "" if invalid.

function save_id_get(obj)
{
	if (obj = "")
		return ""
	
	if (instance_exists(obj))
		return obj.save_id
	
	return ""
}
