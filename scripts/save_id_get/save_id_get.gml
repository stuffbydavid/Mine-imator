/// save_id_get(object)
/// @arg object
/// @desc Safe way to get the save ID of an object. "" if invalid.

var obj = argument0;

if (instance_exists(obj))
	return obj.save_id

return ""