/// render_high_reflections(surf)
/// @arg surf
/// @desc Ray traces scene with reflections

function render_high_reflections(surf)
{
	// Render scene data
	var rtsurf, depthsurf, normalsurf, normalsurf2, materialsurf, samplesurf;
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	render_surface[4] = surface_require(render_surface[4], render_width, render_height)
	render_surface[5] = surface_require(render_surface[5], render_width, render_height)
	render_surface[6] = surface_require(render_surface[6], render_width, render_height)
	render_surface_ssr = surface_require(render_surface_ssr, render_width, render_height)
	rtsurf = render_surface[0]
	depthsurf = render_surface[1]
	normalsurf = render_surface[2]
	normalsurf2 = render_surface[4]
	materialsurf = render_surface[5]
	samplesurf = render_surface[6]
	
	// Material data
	surface_set_target(materialsurf)
	{
		draw_clear_alpha(c_white, 0)
		render_world_start()
		render_world(e_render_mode.MATERIAL)
		render_world_done()
	}
	surface_reset_target()
	
	// Depth and normal data
	surface_set_target_ext(0, depthsurf)
	surface_set_target_ext(1, normalsurf)
	surface_set_target_ext(2, normalsurf2)
	{
		draw_clear_alpha(c_white, 0)
		render_world_start(5000)
		render_world(e_render_mode.HIGH_REFLECTIONS_DEPTH_NORMAL)
		render_world_done()
	}
	surface_reset_target()
	
	random_set_seed(render_sample_current)
	
	render_sample_noise_texture = render_get_noise_texture(render_sample_current)
	
	// Raytrace reflections
	surface_set_target_ext(0, rtsurf)
	surface_set_target_ext(1, render_surface_ssr) // Not enough render surfaces for what we need, temporarily use the result surface
	{
		gpu_set_texrepeat(false)
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_raytrace_uv]
		with (render_shader_obj)
		{
		    shader_set(shader)
		    shader_high_raytrace_uv_set(depthsurf, normalsurf, normalsurf2, materialsurf)
		}
		
		draw_blank(0, 0, render_width, render_height)
		
		with (render_shader_obj)
		    shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	// Resolve RT data to color
	surface_set_target(samplesurf)
	{
		gpu_set_texrepeat(false)
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_raytrace_reflections]
		with (render_shader_obj)
		{
		    shader_set(shader)
		    shader_high_raytrace_reflections_set(rtsurf, render_surface_ssr, surf, normalsurf, normalsurf2, null, materialsurf)
		}
		
		draw_blank(0, 0, render_width, render_height)
		
		with (render_shader_obj)
		    shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	surface_set_target(render_surface_ssr)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface(samplesurf, 0, 0)
	}
	surface_reset_target()
	
	// Apply reflections
	render_high_reflections_apply(surf, materialsurf)
}

/// render_high_reflections_apply(surf)
/// @arg surf
function render_high_reflections_apply(surf, matsurf)
{
	var materialsurf, diffusesurf, applysurf;
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	materialsurf = matsurf
	diffusesurf = render_surface[1]
	applysurf = render_surface[2]
	
	if (render_pass = e_render_pass.MATERIAL)
		render_pass_surf = surface_duplicate(materialsurf)
	
	// Diffuse color (Reflection tint)
	surface_set_target(diffusesurf)
	{
		// Background
		draw_clear_alpha(c_black, 0)
		render_world_background()
		
		// World
		render_world_start()
		render_world_sky()
		render_world(e_render_mode.COLOR)
		render_world_done()
	}
	surface_reset_target()
	
	// Apply reflections
	surface_set_target(applysurf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_reflections_apply]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_reflections_apply_set(render_surface_ssr, materialsurf, diffusesurf)
		}
		
		draw_surface_exists(surf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	// Apply result to result surface
	if (surface_exists(surf))
	{
		surface_set_target(surf)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_exists(applysurf, 0, 0)
		}
		surface_reset_target()
	}
}