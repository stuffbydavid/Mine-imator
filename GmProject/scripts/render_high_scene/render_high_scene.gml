/// render_high_scene()
/// @desc Applies lighting to the scene

function render_high_scene()
{
	var masksurf, resultsurf;
	render_surface_hdr[1] = surface_require(render_surface_hdr[1], render_width, render_height, true, true)
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	masksurf = render_surface[1]
	resultsurf = render_surface_hdr[1] // Render directly to target?
	
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
	
	// Composite
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		// Apply lighting surfaces
		render_shader_obj = shader_map[?shader_high_lighting_apply]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_lighting_apply_set(render_surface_shadows, masksurf, render_surface_material)
		}
		draw_surface_exists(render_surface_diffuse, 0, 0)
		
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	return resultsurf
}
