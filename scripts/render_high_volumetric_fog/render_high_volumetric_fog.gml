/// render_high_volumetric_fog(basesurf, export)
/// @arg basesurf
/// @arg export

function render_high_volumetric_fog(prevsurf, export)
{
	var sampleoffset, depthsurf, resultsurf, samplestart, sampleend;
	sampleoffset = vec3(0)
	samplestart = 0
	sampleend = 0
	
	render_volumetric_fog_offset = 1
	
	if (!render_samples_done || export)
	{
		if (!export)
		{
			samplestart = render_samples
			sampleend = render_samples + 1
		}
		else
		{
			samplestart = 0
			sampleend = project_render_samples
			render_samples = project_render_samples
		}
		
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
		
		for (var s = samplestart; s < sampleend; s++)
		{
			if (render_samples_done && !export)
				continue
			
			render_sun_direction = background_sun_direction
			
			// Render sun depth buffer
			if (export)
			{
				if (s > 1)
				{
					random_set_seed(s)
					
					var xyang, zang, dis;
					xyang = random(360)
					zang = random_range(-180, 180)
					dis = ((background_sunlight_angle * (world_size / 2)) / 57.2958) / 2
					sampleoffset[X] = lengthdir_x(dis, xyang) * lengthdir_x(1, zang)
					sampleoffset[Y] = lengthdir_y(dis, xyang) * lengthdir_x(1, zang)
					sampleoffset[Z] = lengthdir_z(dis, zang)
				}
				
				var angle = vec3_add(vec3_mul(app.background_sun_direction, -5000), sampleoffset);
				angle = vec3_normalize(vec3_mul(angle, -1))
				
				// Depth
				cam_far = cam_far_prev
				render_update_cascades(angle)
				
				for (var i = 0; i < render_cascades_count; i++)
				{
					render_surface_sun_buffer[i] = surface_require(render_surface_sun_buffer[i], project_render_shadows_sun_buffer_size, project_render_shadows_sun_buffer_size)
					surface_set_target(render_surface_sun_buffer[i])
					{
						gpu_set_blendmode_ext(bm_one, bm_zero)
					
						draw_clear(c_white)
						render_world_start_sun(i)
						render_world(e_render_mode.HIGH_LIGHT_SUN_DEPTH)
						render_world_done()
				
						gpu_set_blendmode(bm_normal)
					}
					surface_reset_target()
				}
			}
			else if (app.background_sunlight_color_final = c_black)
			{
				// Sun info needs to be updated for volumetrics
				render_world_start_sun(0)
				render_world_done()
			}
			
			// Render and apply volumetric fog
			var exptemp, dectemp, resultsurftemp;
			render_surface_sun_volume_expo = surface_require(render_surface_sun_volume_expo, render_width, render_height)
			render_surface_sun_volume_dec = surface_require(render_surface_sun_volume_dec, render_width, render_height)
			render_surface[1] = surface_require(render_surface[1], render_width, render_height)
			resultsurftemp = render_surface[1]
			
			for (var i = 0; i < 16; i++)
				render_volumetric_fog_offset[i] = random_range(0, 1)
			
			surface_set_target(resultsurftemp)
			{
				draw_clear_alpha(c_black, 1)
				render_shader_obj = shader_map[?shader_high_volumetric_fog]
				with (render_shader_obj)
				{
					shader_use()
					shader_high_volumetric_fog_set(depthsurf)
				}
				draw_blank(0, 0, render_width, render_height)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
			
			render_surface[2] = surface_require(render_surface[2], render_width, render_height)
			render_surface[3] = surface_require(render_surface[3], render_width, render_height)
			exptemp = render_surface[2]
			dectemp = render_surface[3]
			
			// Draw temporary exponent surface
			surface_set_target(exptemp)
			{
				draw_clear_alpha(c_black, 1)
				draw_surface_exists(render_surface_sun_volume_expo, 0, 0)
				
				if (s = 0 || render_samples_clear)
					draw_clear_alpha(c_black, 1)
			}
			surface_reset_target()
			
			surface_set_target(dectemp)
			{
				draw_clear_alpha(c_black, 1)
				draw_surface_exists(render_surface_sun_volume_dec, 0, 0)
				
				if (s = 0 || render_samples_clear)
					draw_clear_alpha(c_black, 1)
			}
			surface_reset_target()
			
			// Add light shadow to buffer
			surface_set_target_ext(0, render_surface_sun_volume_expo)
			surface_set_target_ext(1, render_surface_sun_volume_dec)
			{
				render_shader_obj = shader_map[?shader_high_samples_add]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_high_samples_add_set(exptemp, dectemp)
				}
				draw_surface_exists(resultsurftemp, 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
		}
	}
	
	// Render directly to target?
	resultsurf = render_high_get_apply_surf()
	
	// Add to shadows
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		render_shader_obj = shader_map[?shader_high_volumetric_fog_apply]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_volumetric_fog_apply_set(render_surface_sun_volume_expo, render_surface_sun_volume_dec, render_samples)
		}
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	if (export)
	{
		surface_free(render_surface_sun_volume_expo)
		surface_free(render_surface_sun_volume_dec)
		surface_free(render_surface_sun_buffer)
		
		render_world_start()
		bbox_update_visible()
		render_world_done()
	}
	
	return resultsurf
}
