/// render_high_shadows()

function render_high_shadows()
{
	var resultsurftemp, specresultsurftemp, sampleoffset, sunout, samplestart, sampleend, lightlist;
	sampleoffset = point3D(0, 0, 0)
	sunout = (background_sunlight_color_final != c_black)
	samplestart = 0
	sampleend = 0
	lightlist = array()
	
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
	
	render_surface_specular = surface_require(render_surface_specular, render_width, render_height)
	surface_set_target(render_surface_specular)
	{
		draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()
	
	// Clear shadows
	surface_set_target(render_surface_shadows)
	{
		draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()
	
	surface_set_target(render_surface_specular)
	{
		draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()
	
	#region Sun
	
	if (sunout)
	{
		// Scatter position
		if (render_sample_current > 1)
		{
			random_set_seed(render_sample_current)
			
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
		taa_matrix = MAT_IDENTITY
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
	
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	render_surface[3] = surface_require(render_surface[3], render_width, render_height)
	resultsurftemp = render_surface[2]
	specresultsurftemp = render_surface[3]
	
	taa_matrix = taa_jitter_matrix
	
	surface_set_target_ext(0, resultsurftemp)
	surface_set_target_ext(1, specresultsurftemp)
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
	
	surface_set_target(render_surface_specular)
	{
		gpu_set_blendmode(bm_add)
		draw_surface_exists(specresultsurftemp, 0, 0)
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
			
			if (render_sample_current > 1)
			{
				random_set_seed(render_sample_current)
					
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
				
				taa_matrix = MAT_IDENTITY
				
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
						render_world_start_light(world_pos, point3D_add(world_pos, look), sampleoffset, id)
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
				
				taa_matrix = taa_jitter_matrix
				
				// Shadows
				with (app)
				{
					render_surface[2] = surface_require(render_surface[2], render_width, render_height)
					render_surface[3] = surface_require(render_surface[3], render_width, render_height)
					resultsurftemp = render_surface[2]
					specresultsurftemp = render_surface[3]
					
					surface_set_target_ext(0, resultsurftemp)
					surface_set_target_ext(1, specresultsurftemp)
					{
						draw_clear(c_black)
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
				
				taa_matrix = MAT_IDENTITY
				
				// Depth
				render_surface_spot_buffer = surface_require(render_surface_spot_buffer, app.project_render_shadows_spot_buffer_size, app.project_render_shadows_spot_buffer_size)
				surface_set_target(render_surface_spot_buffer)
				{
					gpu_set_blendmode_ext(bm_one, bm_zero)
					
					draw_clear(c_white)
					
					render_world_start_light(world_pos, lookat, sampleoffset, id)
					
					// Only render depth for shadows if the light source isn't shadowless
					if (shadows)
						render_world(e_render_mode.HIGH_LIGHT_SPOT_DEPTH)
					
					render_world_done()
					
					gpu_set_blendmode(bm_normal)
				}
				surface_reset_target()
				
				taa_matrix = taa_jitter_matrix
				
				// Shadows
				with (app)
				{
					render_surface[2] = surface_require(render_surface[2], render_width, render_height)
					render_surface[3] = surface_require(render_surface[3], render_width, render_height)
					resultsurftemp = render_surface[2]
					specresultsurftemp = render_surface[3]
					
					surface_set_target_ext(0, resultsurftemp)
					surface_set_target_ext(1, specresultsurftemp)
					{
						draw_clear(c_black)
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
			
			// Add to specular
			surface_set_target(render_surface_specular)
			{
				gpu_set_blendmode(bm_add)
				draw_surface_exists(specresultsurftemp, 0, 0)
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
		}
	}
	
	#endregion
	
	// Render shadowless point lights
	render_high_shadows_shadowless()
	
	// Apply subsurface scattering
	render_high_subsurface_scatter()
}

function render_high_shadows_shadowless()
{
	if (ds_list_size(render_shadowless_point_list) > 0)
	{
		var resultsurftemp, lights, batches, specresultsurftemp, resultsurftemp;
		lights = ds_list_size(render_shadowless_point_list)
		batches = 0
			
		while (lights > 0)
		{
			for (var l = 0; l < 31; l++)
			{
				if (lights = 0)
					continue
					
				var light = render_shadowless_point_list[| l + (batches * 31)];
					
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 0] = light.world_pos[X]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 1] = light.world_pos[Y]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 2] = light.world_pos[Z]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 3] = light.value[e_value.LIGHT_RANGE]
					
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 4] = (color_get_red(light.value[e_value.LIGHT_COLOR]) / 255)
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 5] = (color_get_green(light.value[e_value.LIGHT_COLOR]) / 255)
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 6] = (color_get_blue(light.value[e_value.LIGHT_COLOR]) / 255)
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 7] = light.value[e_value.LIGHT_FADE_SIZE]
					
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 8] = light.value[e_value.LIGHT_STRENGTH]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 9] = light.value[e_value.LIGHT_SPECULAR_STRENGTH]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 10] = 1
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 11] = 1
				render_shadowless_point_amount++
				lights--
			}
			
			// Render lights
			render_surface[2] = surface_require(render_surface[2], render_width, render_height)
			render_surface[3] = surface_require(render_surface[3], render_width, render_height)
			resultsurftemp = render_surface[2]
			specresultsurftemp = render_surface[3]
			
			surface_set_target_ext(0, resultsurftemp)
			surface_set_target_ext(1, specresultsurftemp)
			{
				draw_clear(c_black)
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
				
			surface_set_target(render_surface_specular)
			{
				gpu_set_blendmode(bm_add)
				draw_surface_exists(specresultsurftemp, 0, 0)
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
				
			batches++
			render_shadowless_point_amount = 0
		}
			
		ds_list_clear(render_shadowless_point_list)
	}
	
	if (render_pass = e_render_pass.SHADOWS || render_pass = e_render_pass.INDIRECT_SHADOWS) 
		render_pass_surf = surface_duplicate(render_surface_shadows)
	
	if (render_pass = e_render_pass.SPECULAR)
		render_pass_surf = surface_duplicate(render_surface_specular)
}