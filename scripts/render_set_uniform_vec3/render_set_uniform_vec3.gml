/// render_set_uniform_vec3(name, x, y, z)
/// @arg name
/// @arg x
/// @arg y
/// @arg z
/// @desc Sets a 3-float uniform (if it exists) of the currently selected shader.

function render_set_uniform_vec3(name, xx, yy, zz)
{
	if (!render_update_uniform(name, [xx, yy, zz], true))
		return 0
		
	var uniform = render_shader_obj.uniform_map[?name];
	
	if (!is_undefined(uniform) && uniform > -1)
		shader_set_uniform_f(uniform, xx, yy, zz)
}
