/// render_high_fog(basesurf)
/// @arg basesurf

function render_high_fog(basesurf)
{
	var fogsurf;
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	fogsurf = render_surface[0]
	
	surface_set_target(fogsurf)
	{
		draw_clear(c_black)
		render_world_start()
		render_world(e_render_mode.HIGH_FOG)
		render_world_done()
	}
	surface_reset_target()
	
	// Copy into separate surface
	render_surface[4] = surface_require(render_surface[4], render_width, render_height);
	var scenesurf = render_surface[4];
	
	surface_set_target(scenesurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface_exists(basesurf, 0, 0)
	}
	surface_reset_target()
	
	// Scene post processing
	surface_set_target(basesurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface_exists(scenesurf, 0, 0)
		
		// Draw fog
		if (background_fog_show)
		{
			render_shader_obj = shader_map[?shader_high_fog_apply]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_fog_apply_set(fogsurf)
			}
			draw_blank(0, 0, render_width, render_height)
			with (render_shader_obj)
				shader_clear()
		}
		
		// Alpha fix
		gpu_set_blendmode_ext(bm_src_color, bm_one) 
		if (render_background)
			draw_box(0, 0, render_width, render_height, false, c_black, 1)
		else
		{
			render_world_start()
			render_world(e_render_mode.ALPHA_FIX)
			render_world_done()
		}
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
}
