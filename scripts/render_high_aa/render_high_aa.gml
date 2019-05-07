/// render_high_aa(basesurf)
/// @arg basesurf

var prevsurf, resultsurf;
prevsurf = argument0
resultsurf = render_high_get_apply_surf()
	
surface_set_target(resultsurf)
{
	draw_clear_alpha(c_black, 0)
		
	render_shader_obj = shader_map[?shader_high_aa]
	with (render_shader_obj)
		shader_use()
	draw_surface_exists(prevsurf, 0, 0)
	with (render_shader_obj)
		shader_clear()
		
	// Alpha fix
	gpu_set_blendmode_ext(bm_src_color, bm_one) 
	if (render_background)
		draw_box(0, 0, render_width, render_height, false, c_black, 1)
	else
	{
		render_world_start()
		render_world(e_render_mode.ALPHA_TEST)
		render_world_done()
	}
	gpu_set_blendmode(bm_normal)
		
}
surface_reset_target()

return resultsurf