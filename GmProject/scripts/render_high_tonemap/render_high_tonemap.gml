/// render_high_tonemap(surf)
/// @arg surf

function render_high_tonemap(surf)
{
	var resultsurf = render_high_get_apply_surf();
	
	// Tonemap / gamma
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_tonemap]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_tonemap_set()
		}
		
		gpu_set_blendmode_ext(bm_one, bm_zero)
		draw_surface_exists(surf, 0, 0)
		gpu_set_blendmode(bm_normal)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	return resultsurf
}
