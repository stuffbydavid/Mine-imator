/// render_pass_capture(pass, surf)
/// @arg pass
/// @arg surf

function render_pass_capture(pass, surf)
{
	if (render_pass != pass && render_pass != e_render_pass.ALL)
		return 0
	
	var copysurf;
	if (surface_exists(surf))
	{
		var channel = render_pass_channel(pass)
		copysurf = surface_create(surface_get_width(surf), surface_get_height(surf))
		surface_set_target(copysurf)
		{
			draw_clear_alpha(c_black, 0)
			gpu_set_blendmode_ext(bm_one, bm_zero)
			
			render_shader_obj = shader_map[?shader_render_pass]
			with (render_shader_obj)
			{
				shader_set(shader)
				render_set_uniform_int("uChannel", channel)
			}
			
			draw_surface_exists(surf, 0, 0)
			
			with (render_shader_obj)
				shader_clear()
			
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
	}
	else
		copysurf = surface_duplicate(surf)
	
	if (render_pass = e_render_pass.ALL)
	{
		if (surface_exists(render_pass_surfs[pass]))
			surface_free(render_pass_surfs[pass])
		
		render_pass_surfs[pass] = copysurf
	}
	else
	{
		if (surface_exists(render_pass_surf))
			surface_free(render_pass_surf)
		
		render_pass_surf = copysurf
	}
}