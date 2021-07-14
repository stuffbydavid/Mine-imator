/// render_update_uniform(name, val, isarray)
/// @arg name
/// @arg val
/// @arg isarray

function render_update_uniform(name, val, isarray)
{
	return true
	
	if (!shader_check_uniform)
		return true
	
	var map = render_shader_obj.uniform_value_map;
	var oldval = map[?name];
	
	if (isarray && (oldval = undefined || !array_equals(oldval, val)))
	{
		map[?name] = array_copy_1d(val)
		return true
	}
	else if (!isarray && (oldval = undefined || oldval != val))
	{
		map[?name] = val
		return true
	}
	
	return false
}