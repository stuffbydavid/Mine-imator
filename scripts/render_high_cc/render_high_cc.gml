/// render_high_cc(basesurf)
/// @arg basesurf

function render_high_cc(prevsurf)
{
	var resultsurf = render_high_get_apply_surf();
	
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_color_correction]
		with (render_shader_obj)
			shader_use()
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	return resultsurf
}
