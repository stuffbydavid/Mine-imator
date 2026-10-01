/// @desc Renders the scene in low quality.

function render_low()
{
	var surf, finalsurf, cacheddepth;
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	surf = render_surface[0]
	
	render_alpha_hash = false
	render_alpha_hash_force = true
	
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha)
		
		// Background
		render_world_background()
		
		// World
		render_world_start()
		render_world_sky()
		render_world(render_lights ? e_render_mode.COLOR_FOG_LIGHTS : e_render_mode.COLOR_FOG)
		render_world_done()

		if (render_background)
		{
			render_set_projection_ortho(0, 0, render_width, render_height, 0)
			gpu_set_colorwriteenable(false, false, false, true)
			gpu_set_blendmode_ext(bm_one, bm_zero)
			draw_box(0, 0, render_width, render_height, false, c_black, 1)
			gpu_set_colorwriteenable(true, true, true, true)
		}

		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	if (render_effects_done)
		return 0
	
	// Camera depth for depth-aware post effects
	if (render_camera_dof)
	{
		cacheddepth = render_surface_depth
		render_surface_depth = render_surface_depth_low
		render_surface_depth = surface_require(render_surface_depth, render_width, render_height, true, surface_r32float)
		render_surface_depth_low = render_surface_depth
		surface_set_target(render_surface_depth)
		{
			draw_clear(c_white)
			gpu_set_blendmode_ext(bm_one, bm_zero)
			render_world_start(depth_far)
			render_world(e_render_mode.DEPTH)
			render_world_done()
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
	}

	finalsurf = render_post(surf)
	if (render_camera_dof)
		render_surface_depth = cacheddepth
	
	if (setting_quick_mode_aa)
		finalsurf = render_high_aa(finalsurf)
	
	render_target = surface_require(render_target, render_width, render_height)
	surface_set_target(render_target)
	{
		draw_clear_alpha(c_black, 0)
		gpu_set_blendmode_ext(bm_one, bm_zero)
		draw_surface_exists(finalsurf, 0, 0)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	render_alpha_hash_force = false
}
