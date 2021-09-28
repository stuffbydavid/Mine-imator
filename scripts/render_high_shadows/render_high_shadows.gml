/// render_high_shadows(export)
/// @arg export

function render_high_shadows(export)
{
	var resultsurftemp, sampleoffset, sunout, samplestart, sampleend, lightlist;
	sampleoffset = point3D(0, 0, 0)
	sunout = (background_sunlight_color_final != c_black)
	samplestart = 0
	sampleend = 0
	lightlist = array()
	
	// Set samples to setting
	if (!export)
	{	
		if (render_samples_done)
			return 0
		
		samplestart = render_samples - 1
		sampleend = render_samples
	}
	else
	{
		samplestart = 0
		sampleend = project_render_samples
		render_samples = project_render_samples
	}
	
	// Get visible lights
	with (obj_timeline)
	{
		// Light source check
		if (type != e_tl_type.POINT_LIGHT && type != e_tl_type.SPOT_LIGHT)
			continue
		
		// Hidden
		if (!value_inherit[e_value.VISIBLE] || hide)
			continue
		
		// Shadowless pointlight
		if (type = e_tl_type.POINT_LIGHT && !shadows)
		{
			ds_list_add(render_shadowless_point_list, id)
			continue
		}
		
		lightlist = array_add(lightlist, id)
	}
	
	// Get number of lights (to divide brightness by)
	render_light_amount = array_length(lightlist) + ds_list_size(render_shadowless_point_list)
	
	// Initial shadow surface from sun
	render_surface_shadows = surface_require(render_surface_shadows, render_width, render_height)
	surface_set_target(render_surface_shadows)
	{
		draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()
	
	// Sample lights
	for (var s = samplestart; s < sampleend; s++)
	{
		// Clear shadows
		if (export)
		{
			surface_set_target(render_surface_shadows)
			{
				draw_clear_alpha(c_black, 1)
			}
			surface_reset_target()
		}
		
		#region Sun
		
		if (sunout)
		{
			// Scatter position
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
			
			// Update camera (position) if not previously initialized
			render_world_start()
			
			// Depth
			render_surface_sun_buffer = surface_require(render_surface_sun_buffer, project_render_shadows_sun_buffer_size, project_render_shadows_sun_buffer_size)
			surface_set_target(render_surface_sun_buffer)
			{
				gpu_set_blendmode_ext(bm_one, bm_zero)
				
				draw_clear(c_white)
				render_world_start_sun(
					point3D(background_light_data[0], background_light_data[1], background_light_data[2]), 
					point3D(cam_from[X] * background_sunlight_follow, cam_from[Y] * background_sunlight_follow, 0), sampleoffset)
				render_world(e_render_mode.HIGH_LIGHT_SUN_DEPTH)
				render_world_done()
				
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
			
			// Color
			if (app.project_render_shadows_sun_colored)
			{
				render_surface_sun_color_buffer = surface_require(render_surface_sun_color_buffer, project_render_shadows_sun_buffer_size, project_render_shadows_sun_buffer_size)
				surface_set_target(render_surface_sun_color_buffer)
				{
					draw_clear(c_white)
					render_world_start_sun(
						point3D(background_light_data[0], background_light_data[1], background_light_data[2]), 
						point3D(cam_from[X] * background_sunlight_follow, cam_from[Y] * background_sunlight_follow, 0), sampleoffset)
					render_world(e_render_mode.HIGH_LIGHT_SUN_COLOR)
					render_world_done()
				}
				surface_reset_target()
			}
			
			render_world_start()
			bbox_update_visible()
			render_world_done()
		}
		
		render_surface[2] = surface_require(render_surface[2], render_width, render_height)
		resultsurftemp = render_surface[2]
		
		surface_set_target(resultsurftemp)
		{
			draw_clear(c_black)
			render_world_start()
			render_world(sunout ? e_render_mode.HIGH_LIGHT_SUN : e_render_mode.HIGH_LIGHT_NIGHT)
			render_world_done()
		}
		surface_reset_target()
		
		// Add to shadows
		surface_set_target(render_surface_shadows)
		{
			gpu_set_blendmode(bm_add)
			draw_surface_exists(resultsurftemp, 0, 0)
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		
		#endregion
		
		#region User-placed lights
		
		for (var i = 0; i < array_length(lightlist); i++)
		{
			with (lightlist[i])
			{
				var resultsurftemp;
				
				if (!value_inherit[e_value.VISIBLE] || hide || (render_view_current.render && hq_hiding) || (!render_view_current.render && lq_hiding))
					continue
				
				if (s > 1)
				{
					random_set_seed(s)
					
					var xyang, zang, dis;
					xyang = random(360)
					zang = random_range(-180, 180)
					dis = value[e_value.LIGHT_SIZE]/2
					sampleoffset[X] = lengthdir_x(dis, xyang) * lengthdir_x(1, zang)
					sampleoffset[Y] = lengthdir_y(dis, xyang) * lengthdir_x(1, zang)
					sampleoffset[Z] = lengthdir_z(dis, zang)
				}
				
				#region Point light
				
				if (type = e_tl_type.POINT_LIGHT)
				{
					// If shadowless, add to shadowless point light list and continue
					if (!shadows)
					{
						ds_list_add(render_shadowless_point_list, id)
						continue
					}
					
					var atlasx, atlasy, atlassize;
					atlasx = 0
					atlasy = 0
					atlassize = app.project_render_shadows_point_buffer_size
					render_surface_point_atlas_buffer = surface_require(render_surface_point_atlas_buffer, atlassize * 3, atlassize * 2)
					render_surface_point_buffer = surface_require(render_surface_point_buffer, atlassize, atlassize)
					
					// Depth
					for (var d = e_dir.EAST; d < e_dir.amount; d++)
					{
						var look = dir_get_vec3(d);
						if (d = e_dir.DOWN || d = e_dir.UP)
							look[Y] -= 0.0001
						
						surface_set_target(render_surface_point_buffer)
						{
							gpu_set_blendmode_ext(bm_one, bm_zero)
							
							draw_clear(c_white)
							render_world_start_light(world_pos, point3D_add(world_pos, look), sampleoffset, 1, value[e_value.LIGHT_RANGE], 90, value[e_value.LIGHT_COLOR], value[e_value.LIGHT_STRENGTH], value[e_value.LIGHT_FADE_SIZE])
							render_world(e_render_mode.HIGH_LIGHT_POINT_DEPTH)
							
							render_world_done()
							
							gpu_set_blendmode(bm_normal)
						}
						surface_reset_target()
						
						surface_set_target(render_surface_point_atlas_buffer)
						{
							draw_surface(render_surface_point_buffer, atlasx, atlasy)
						}
						surface_reset_target()
						
						atlasx += atlassize
						
						if (atlasx = (atlassize * 3))
						{
							atlasx = 0
							atlasy += atlassize
						}
					}
					
					// Shadows
					with (app)
					{
						render_world_start()
						bbox_update_visible()
						render_world_done()
						
						render_surface[2] = surface_require(render_surface[2], render_width, render_height)
						resultsurftemp = render_surface[2]
						surface_set_target(resultsurftemp)
						{
							draw_clear(c_white)
							render_world_start()
							render_world(e_render_mode.HIGH_LIGHT_POINT)
							render_world_done()
						}
						surface_reset_target()
					}
				}
				
				#endregion
				#region Spot light
				
				else if (type = e_tl_type.SPOT_LIGHT)
				{
					var lookat = point3D_mul_matrix(point3D(0.0001, 1, 0), matrix);
					
					// Depth
					render_surface_spot_buffer = surface_require(render_surface_spot_buffer, app.project_render_shadows_spot_buffer_size, app.project_render_shadows_spot_buffer_size)
					surface_set_target(render_surface_spot_buffer)
					{
						gpu_set_blendmode_ext(bm_one, bm_zero)
						
						draw_clear(c_white)
						
						render_world_start_light(world_pos, lookat, sampleoffset, 1, value[e_value.LIGHT_RANGE], value[e_value.LIGHT_SPOT_RADIUS], value[e_value.LIGHT_COLOR], value[e_value.LIGHT_STRENGTH], value[e_value.LIGHT_FADE_SIZE], value[e_value.LIGHT_SPOT_SHARPNESS])
						
						// Only render depth for shadows if the light source isn't shadowless
						if (shadows)
							render_world(e_render_mode.HIGH_LIGHT_SPOT_DEPTH)
						
						render_world_done()
						
						gpu_set_blendmode(bm_normal)
					}
					surface_reset_target()
					
					// Shadows
					with (app)
					{
						render_world_start()
						bbox_update_visible()
						render_world_done()
						
						render_surface[2] = surface_require(render_surface[2], render_width, render_height)
						resultsurftemp = render_surface[2]
						surface_set_target(resultsurftemp)
						{
							draw_clear(c_white)
							render_world_start()
							render_world(e_render_mode.HIGH_LIGHT_SPOT)
							render_world_done()
						}
						surface_reset_target()
					}
				}
				else
					continue
				
				#endregion
				
				// Add to shadows
				surface_set_target(render_surface_shadows)
				{
					gpu_set_blendmode(bm_add)
					draw_surface_exists(resultsurftemp, 0, 0)
					gpu_set_blendmode(bm_normal)
				}
				surface_reset_target()
			}
		}
		
		#endregion
		
		#region Shadowless point lights
	
		if (ds_list_size(render_shadowless_point_list) > 0)
		{
			var resultsurftemp, lights, batches;
			lights = ds_list_size(render_shadowless_point_list)
			batches = 0
		
			while (lights > 0)
			{
				for (var l = 0; l < 63; l++)
				{
					if (lights = 0)
						continue
				
					var light = render_shadowless_point_list[| l + (batches * 63)];
				
					render_shadowless_point_data[render_shadowless_point_amount * 8 + 0] = light.world_pos[X]
					render_shadowless_point_data[render_shadowless_point_amount * 8 + 1] = light.world_pos[Y]
					render_shadowless_point_data[render_shadowless_point_amount * 8 + 2] = light.world_pos[Z]
					render_shadowless_point_data[render_shadowless_point_amount * 8 + 3] = light.value[e_value.LIGHT_RANGE]
					render_shadowless_point_data[render_shadowless_point_amount * 8 + 4] = (color_get_red(light.value[e_value.LIGHT_COLOR]) / 255) * light.value[e_value.LIGHT_STRENGTH]
					render_shadowless_point_data[render_shadowless_point_amount * 8 + 5] = (color_get_green(light.value[e_value.LIGHT_COLOR]) / 255) * light.value[e_value.LIGHT_STRENGTH]
					render_shadowless_point_data[render_shadowless_point_amount * 8 + 6] = (color_get_blue(light.value[e_value.LIGHT_COLOR]) / 255) * light.value[e_value.LIGHT_STRENGTH]
					render_shadowless_point_data[render_shadowless_point_amount * 8 + 7] = light.value[e_value.LIGHT_FADE_SIZE]
					render_shadowless_point_amount++
					lights--
				}
			
				// Render lights
				render_surface[2] = surface_require(render_surface[2], render_width, render_height)
				resultsurftemp = render_surface[2]
				surface_set_target(resultsurftemp)
				{
					draw_clear(c_white)
					render_world_start()
					render_world(e_render_mode.HIGH_LIGHT_POINT_SHADOWLESS)
					render_world_done()
				}
				surface_reset_target()
			
				// Add to final shadow surface
				surface_set_target(render_surface_shadows)
				{
					gpu_set_blendmode(bm_add)
					draw_surface_exists(resultsurftemp, 0, 0)
					gpu_set_blendmode(bm_normal)
				}
				surface_reset_target()
			
				batches++
				render_shadowless_point_amount = 0
			}
		
			ds_list_clear(render_shadowless_point_list)
		}
	
		#endregion
		
		// Subsurface scattering (viewport)
		if (!export)
			render_high_subsurface_scatter(export)
		
		// Add surface to samples
		var exptemp, dectemp;
		render_surface_shadows_expo = surface_require(render_surface_shadows_expo, render_width, render_height)
		render_surface_shadows_dec = surface_require(render_surface_shadows_dec, render_width, render_height)
		render_surface_sample_temp1 = surface_require(render_surface_sample_temp1, render_width, render_height)
		render_surface_sample_temp2 = surface_require(render_surface_sample_temp2, render_width, render_height)
		exptemp = render_surface_sample_temp1
		dectemp = render_surface_sample_temp2
		
		// Draw temporary exponent surface
		surface_set_target(exptemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_shadows_expo, 0, 0)
			
			if (s = 0 || render_samples_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()
		
		surface_set_target(dectemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_shadows_dec, 0, 0)
			
			if (s = 0 || render_samples_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()
		
		// Add light shadow to buffer
		surface_set_target_ext(0, render_surface_shadows_expo)
		surface_set_target_ext(1, render_surface_shadows_dec)
		{
			render_shader_obj = shader_map[?shader_high_shadows_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_shadows_add_set(exptemp, dectemp)
			}
			draw_surface_exists(render_surface_shadows, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
	}
	
	// Unpack samples
	surface_set_target(render_surface_shadows)
	{
		draw_clear_alpha(c_black, 1)
		
		render_shader_obj = shader_map[?shader_high_samples_unpack]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_samples_unpack_set(render_surface_shadows_expo, render_surface_shadows_dec, render_samples)
		}
		draw_blank(0, 0, render_width, render_height)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	// Subsurface scatter (export)
	if (export)
		render_high_subsurface_scatter(export)
	
	// Free surfaces
	if (export)
	{
		surface_free(render_surface_shadows_expo)
		surface_free(render_surface_shadows_dec)
		surface_free(render_surface_sun_buffer)
		surface_free(render_surface_sun_color_buffer)
		
		surface_free(render_surface_point_buffer)
		surface_free(render_surface_point_atlas_buffer)
	}
}
