/// render_high_grain(basesurf)
/// @arg basesurf

function render_high_grain(prevsurf)
{
	var resultsurf = render_high_get_apply_surf();
	
	// Noise texture
	var size = max(ceil(render_width/8), ceil(render_height/8));
	render_grain_noise = surface_require(render_grain_noise, size, size)
	render_generate_noise(size, size, render_grain_noise)
	
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_noise]
		with (render_shader_obj)
			shader_use()
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	return resultsurf
}
