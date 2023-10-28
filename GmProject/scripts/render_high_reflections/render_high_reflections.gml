/// render_high_reflections(surf)
/// @arg surf
/// @desc Ray traces scene with reflections

function render_high_reflections(surf)
{
	// Raytrace
	render_surface_specular = surface_require(render_surface_specular, render_width, render_height, true)
	surface_set_target(render_surface_specular)
	{
		gpu_set_texrepeat(false)
		draw_clear_alpha(c_black, 1)
		
		render_shader_obj = shader_map[?shader_high_raytrace]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_raytrace_set(e_raytrace.REFLECTIONS, surf)
		}
		
		draw_blank(0, 0, render_width, render_height)
		
		with (render_shader_obj)
			shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	// Resolve
	render_surface_hdr[0] = surface_require(render_surface_hdr[0], render_width, render_height, true)
	surface_set_target(render_surface_hdr[0])
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_raytrace_resolve]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_raytrace_resolve_set()
		}
		
		draw_surface_exists(render_surface_specular, 0, 0)
		
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	// Add
	render_surface_hdr[2] = surface_require(render_surface_hdr[2], render_width, render_height, true, true)
	surface_set_target(render_surface_hdr[2])
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_add]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_add_set(render_surface_hdr[0], 1)
		}
		draw_surface_exists(surf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface_exists(render_surface_hdr[2], 0, 0)
	}
	surface_reset_target()
	
	if (render_pass = e_render_pass.REFLECTIONS)
		render_pass_surf = surface_duplicate(render_surface_hdr[0])
}
