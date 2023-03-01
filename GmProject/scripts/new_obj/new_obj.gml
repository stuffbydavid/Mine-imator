/// new_obj(object)
/// @arg object

function new_obj(obj)
{
	return instance_create_depth(0, 0, 0, obj)
}
