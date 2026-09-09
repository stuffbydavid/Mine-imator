/// render_high_indirect()
/// @desc Ray traces shadow surf for light bounces, returns indirect lighting buffer

function render_high_indirect()
{
	var ww, hh;
	ww = ceil(render_width/render_raytrace_res_ratio)
	hh = ceil(render_height/render_raytrace_res_ratio)
	
	// Raytrace
	render_surface_raydata = surface_require(render_surface_raydata, ww, hh, false, e_surface_format.rgba32float)
	surface_set_target(render_surface_raydata)
	{
		gpu_set_texrepeat(false)
		draw_clear_alpha(c_black, 1)
		
		render_shader_obj = shader_map[?shader_high_indirect_hit]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_indirect_hit_set()
		}
		
		gpu_set_blendmode_ext(bm_one, bm_zero)
		draw_blank(0, 0, ww, hh)
		gpu_set_blendmode(bm_normal)
		
		with (render_shader_obj)
			shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	// Pre-calculate the light leaving each surface once instead of rebuilding it for every resolve sample
	render_surface_hdr[0] = surface_require(render_surface_hdr[0], render_width, render_height, true, e_surface_format.rgba32float)
	surface_set_target(render_surface_hdr[0])
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_indirect_source]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_indirect_source_set()
		}
		
		draw_surface_exists(render_surface_diffuse, 0, 0)
		
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	// Resolve
	render_surface_hdr[1] = surface_require(render_surface_hdr[1], render_width, render_height, true, e_surface_format.rgba32float)
	surface_set_target(render_surface_hdr[1])
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_indirect_resolve]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_indirect_resolve_set()
		}
		
		gpu_set_texfilter(false)
		draw_surface_ext(render_surface_raydata, 0, 0, render_width / ww, render_height / hh, 0, c_white, 1)
		
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	// Blur result
	if (app.project_render_indirect_blur_radius > 0)
	{
		surface_set_target(render_surface_hdr[0])
		{
			draw_clear_alpha(c_black, 0)
			
			render_shader_obj = shader_map[?shader_high_indirect_blur]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_indirect_blur_set()
			}
			
			draw_surface_exists(render_surface_hdr[1], 0, 0)
			
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
	}
	
	var indirectsurf = (app.project_render_indirect_blur_radius > 0 ? render_surface_hdr[0] : render_surface_hdr[1]);
	
	// Add
	surface_set_target(render_surface_shadows)
	{
		gpu_set_blendmode(bm_add)
		draw_surface_exists(indirectsurf, 0, 0)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	if (render_pass = e_render_pass.INDIRECT)
		render_pass_surf = surface_duplicate(indirectsurf)
	
	if (render_pass = e_render_pass.INDIRECT_SHADOWS)
		render_pass_surf = surface_duplicate(render_surface_shadows)
}
