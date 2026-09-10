/// render_high_reflections(surf)
/// @arg surf
/// @desc Ray traces scene with reflections

function render_high_reflections(surf)
{
	var ww, hh, sourcesurf;
	ww = ceil(render_width/render_raytrace_res_ratio)
	hh = ceil(render_height/render_raytrace_res_ratio)
	
	// Raytrace
	render_surface_raydata = surface_require(render_surface_raydata, ww, hh, false, e_surface_format.rgba32float)
	surface_set_target(render_surface_raydata)
	{
		gpu_set_texrepeat(false)
		draw_clear_alpha(c_black, 1)
		
		render_shader_obj = shader_map[?shader_high_reflections_hit]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_reflections_hit_set()
		}
		
		gpu_set_blendmode_ext(bm_one, bm_zero)
		draw_blank(0, 0, ww, hh)
		gpu_set_blendmode(bm_normal)
		
		with (render_shader_obj)
			shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	// Make a copy of current scene for fresh add
	surface_set_target(render_surface_specular)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface_exists(surf, 0, 0)
	}
	surface_reset_target()
	
	for (var bounce = 0; bounce < render_reflections_bounces; bounce++)
	{
		// first bounce uses fallback colors (render_surface_shadows, set by render_high_scene), future bounces use current render with established reflections
		sourcesurf = (bounce = 0 ? render_surface_shadows : surf)
		
		// Resolve reflections pass
		render_surface_hdr[0] = surface_require(render_surface_hdr[0], render_width, render_height, true, e_surface_format.rgba32float)
		surface_set_target(render_surface_hdr[0])
		{
			draw_clear_alpha(c_black, 0)
			
			render_shader_obj = shader_map[?shader_high_reflections_resolve]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_reflections_resolve_set(sourcesurf)
			}
			
			gpu_set_texfilter(false)
			draw_surface_ext(render_surface_raydata, 0, 0, render_width / ww, render_height / hh, 0, c_white, 1)
			
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
		
		// Add to render (pre-reflections scene + current reflection pass), used in future bounces
		surface_set_target(surf)
		{
			draw_clear_alpha(c_black, 0)
			
			render_shader_obj = shader_map[?shader_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_add_set(render_surface_hdr[0], 1)
			}
			draw_surface_exists(render_surface_specular, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
	}
	
	if (render_pass = e_render_pass.REFLECTIONS)
		render_pass_surf = surface_duplicate(render_surface_hdr[0])
}
