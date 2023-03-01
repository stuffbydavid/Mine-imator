/// render_high_tonemap(surf)
/// @arg surf

function render_high_tonemap(surf)
{
	var prevsurf;
	render_surface_hdr[0] = surface_require(render_surface_hdr[0], render_width, render_height, true)
	prevsurf = render_surface_hdr[0]
	
	surface_set_target(prevsurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface_exists(surf, 0, 0)
	}
	surface_reset_target()
	
	//render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	//surf = render_surface[0]
	
	// Tonemap / gamma
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_tonemap]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_tonemap_set(render_surface[1])
		}
		
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	return surf
}
