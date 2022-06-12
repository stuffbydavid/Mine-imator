/// render_high_volumetric_fog(basesurf)
/// @arg basesurf

function render_high_volumetric_fog(prevsurf)
{
	var depthsurf, resultsurf;
	
	// Render whole world for depth, but only store a limited range
	render_surface[5] = surface_require(render_surface[5], render_width, render_height)
	depthsurf = render_surface[5]
	surface_set_target(depthsurf)
	{
		draw_clear_alpha(c_white, 1)
		gpu_set_blendmode_ext(bm_one, bm_zero)
		
		render_world_start(10000)
		render_world(e_render_mode.DEPTH_NO_SKY)
		render_world_done()
		
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	render_sun_direction = background_sun_direction
	
	if (app.background_sunlight_color_final = c_black)
	{
		// Sun info needs to be updated for volumetrics
		render_update_cascades(app.background_sun_direction)
		render_world_start_sun(0)
		render_world_done()
	}
	
	// Render and apply volumetric fog
	render_sample_noise_texture = render_get_noise_texture(render_sample_current)
	
	// Render directly to target?
	resultsurf = render_high_get_apply_surf()
	
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 1)
		render_shader_obj = shader_map[?shader_high_volumetric_fog]
		with (render_shader_obj)
		{
			shader_use()
			shader_high_volumetric_fog_set(depthsurf)
		}
		
		draw_surface(prevsurf, 0, 0)
		
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	return resultsurf
}
