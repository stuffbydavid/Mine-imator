/// render_select(mode, selectsurface)
/// @arg mode
/// @arg selectsurface

function render_select(mode, selectsurface)
{
	// Draw selection on separate surface
	var hlsurf = surface_require(selectsurface, render_width, render_height);
	
	render_alpha_hash = false
	render_alpha_hash_force = true
	
	surface_set_target(hlsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_world_start()
		render_world(mode)
		render_world_done()
	}
	surface_reset_target()
	
	render_alpha_hash_force = false
	
	// Draw border
	if (surface_exists(render_target))
	{
		surface_set_target(render_target)
		{
			gpu_set_texrepeat(false)
			render_shader_obj = shader_map[?shader_border]
			with (render_shader_obj)
			{
				border_mode = mode
				shader_use()
			}
			draw_surface_exists(hlsurf, 0, 0)
			with (render_shader_obj)
				shader_reset()
			
			gpu_set_texrepeat(true)
		}
		surface_reset_target()
	}
	
	return hlsurf
}
