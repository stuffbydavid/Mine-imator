/// render_set_uniform_color(uniform, color, alpha)
/// @arg uniform
/// @arg color
/// @arg alpha
function render_set_uniform_color(name, color, alpha)
{
	// Object color of shaderpack geometry
	if (render_mode = e_render_mode.SHADERPACK && name = "uBlendColor")
		shaderpack_set_color(color, alpha)
	
	var uniform = render_shader_obj.uniform_map[?name];
	if (!is_undefined(uniform) && uniform > -1)
		shader_set_uniform_color(uniform, color, alpha)
}
