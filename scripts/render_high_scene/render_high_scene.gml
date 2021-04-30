/// render_high_scene(ssaosurf, shadowssurf)
/// @arg ssaosurf
/// @arg shadowssurf
/// @desc Applies SSAO and shadows onto the scene

function render_high_scene(ssaosurf, shadowssurf)
{
	var scenesurf, masksurf, resultsurf, materialsurf;
	
	render_surface[2] = surface_require(render_surface[2], render_width, render_height, true)
	scenesurf = render_surface[2]
	
	render_surface[4] = surface_require(render_surface[4], render_width, render_height, true)
	masksurf = render_surface[4]
	
	render_surface[5] = surface_require(render_surface[5], render_width, render_height, true)
	materialsurf = render_surface[5]
	
	// Render directly to target?
	if (render_effects_done)
	{
		render_target = surface_require(render_target, render_width, render_height, true)
		resultsurf = render_target
	}
	else
	{
		render_surface[3] = surface_require(render_surface[3], render_width, render_height, true)
		resultsurf = render_surface[3]
	}
	
	surface_set_target(scenesurf)
	{
		// Background
		draw_clear_alpha(c_black, 0)
		render_world_background()
		
		// World
		render_world_start()
		render_world_sky()
		render_world(e_render_mode.COLOR)
		render_world_done()
		
		// 2D mode
		render_set_projection_ortho(0, 0, render_width, render_height, 0)
		
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
	
	if (setting_render_pass = e_render_pass.DIFFUSE)
		render_pass_surf = surface_duplicate(scenesurf)
	
	// Render lighting mask for background
	surface_set_target(masksurf)
	{
		draw_clear(c_black)
		render_world_start()
		render_world(e_render_mode.SCENE_TEST)
		render_world_done()
		
		// 2D mode
		render_set_projection_ortho(0, 0, render_width, render_height, 0)
		
		// Alpha fix
		gpu_set_blendmode_ext(bm_src_color, bm_one) 
		draw_box(0, 0, render_width, render_height, false, c_black, 1)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	// Material pass
	surface_set_target(materialsurf)
	{
		draw_clear(c_black)
		render_world_start()
		render_world(e_render_mode.MATERIAL)
		render_world_done()
		
		// 2D mode
		render_set_projection_ortho(0, 0, render_width, render_height, 0)
		
		// Alpha fix
		gpu_set_blendmode_ext(bm_src_color, bm_one) 
		draw_box(0, 0, render_width, render_height, false, c_black, 1)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	// Composite
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		// Apply lighting surfaces
		render_shader_obj = shader_map[?shader_high_lighting_apply]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_lighting_apply_set(ssaosurf, shadowssurf, masksurf, materialsurf)
		}
		draw_surface_exists(scenesurf, 0, 0)
		
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	return resultsurf
}
