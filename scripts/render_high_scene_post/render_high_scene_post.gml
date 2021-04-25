/// render_high_scene_post(basesurf, shadowsurf, fogsurf)
/// @arg basesurf
/// @arg shadowsurf
/// @arg fogsurf
/// @desc Renders desaturated night shadows and fog

function render_high_scene_post(basesurf, shadowsurf, fogsurf)
{
	if ((!render_shadows || !background_desaturate_night) && !background_fog_show)
		return 0
	
	// Copy into separate surface
	render_surface[4] = surface_require(render_surface[4], render_width, render_height, true);
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
		
		// Desaturate based on light level
		if (render_shadows && background_desaturate_night)
		{
			render_shader_obj = shader_map[?shader_high_light_desaturate]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_light_desaturate_set(shadowsurf, app.background_desaturate_night_amount)
			}
			draw_surface_exists(scenesurf, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		
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
