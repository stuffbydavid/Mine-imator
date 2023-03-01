/// render_high_ca(basesurf)
/// @arg basesurf

function render_high_ca(prevsurf)
{
	var resultsurf = render_high_get_apply_surf();
	
	gpu_set_texrepeat(false)
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_ca]
		with (render_shader_obj)
			shader_use()
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	gpu_set_texrepeat(true)
	
	return resultsurf
}
