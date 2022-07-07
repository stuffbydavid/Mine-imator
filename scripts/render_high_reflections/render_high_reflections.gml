/// render_high_reflections(surf)
/// @arg surf
/// @desc Ray traces scene with reflections

function render_high_reflections(surf)
{
	// Render scene data
	var rtsurf, rtsurf2;
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	render_surface_ssr = surface_require(render_surface_ssr, render_width, render_height)
	rtsurf = render_surface[1]
	rtsurf2 = render_surface[2]
	
	// Raytrace reflections
	surface_set_target_ext(0, rtsurf)
	surface_set_target_ext(1, rtsurf2) // Surface we have to use much later, no harm in borrowing it now to keep targets low
	{
		gpu_set_texrepeat(false)
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_raytrace_uv]
		with (render_shader_obj)
		{
		    shader_set(shader)
		    shader_high_raytrace_uv_set(render_surface_depth, render_surface_normal, render_surface_normal_ext, render_surface_material)
		}
		
		draw_blank(0, 0, render_width, render_height)
		
		with (render_shader_obj)
		    shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	// Resolve RT data to color
	surface_set_target(render_surface_ssr)
	{
		gpu_set_texrepeat(false)
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_raytrace_reflections]
		with (render_shader_obj)
		{
		    shader_set(shader)
		    shader_high_raytrace_reflections_set(rtsurf, rtsurf2, surf, render_surface_normal, render_surface_normal_ext, null, render_surface_material)
		}
		
		draw_blank(0, 0, render_width, render_height)
		
		with (render_shader_obj)
		    shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	// Apply reflections
	render_high_reflections_apply(surf)
}

/// render_high_reflections_apply(surf)
/// @arg surf
function render_high_reflections_apply(surf)
{
	var prevsurf;
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	prevsurf = render_surface[1]
	
	// Make copy of current render
	surface_set_target(prevsurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface_exists(surf, 0, 0)
	}
	surface_reset_target()
	
	// Apply reflections
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_reflections_apply]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_reflections_apply_set(render_surface_ssr, render_surface_material, render_surface_diffuse)
		}
		
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
}