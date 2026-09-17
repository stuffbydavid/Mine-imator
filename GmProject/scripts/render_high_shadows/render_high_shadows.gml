/// render_high_shadows()

function render_high_shadows()
{
	// Reuse the completed pass when both the shadow maps and G-buffers are stable
	if (render_shadow_pass_cache_enabled && render_shadow_pass_cache_ready &&
		surface_exists(render_surface_shadows_cache) && surface_exists(render_surface_specular_shadows) &&
		surface_get_width(render_surface_shadows_cache) = render_width && surface_get_height(render_surface_shadows_cache) = render_height &&
		surface_get_width(render_surface_specular_shadows) = render_width && surface_get_height(render_surface_specular_shadows) = render_height)
	{
		aa_matrix = aa_jitter_matrix
		render_surface_shadows = surface_require(render_surface_shadows, render_width, render_height, false, e_surface_format.rgba32float)
		render_surface_specular = surface_require(render_surface_specular, render_width, render_height, false, e_surface_format.rgba32float)
		render_high_copy_shadow_surface(render_surface_shadows, render_surface_shadows_cache)
		render_high_copy_shadow_surface(render_surface_specular, render_surface_specular_shadows)
		render_pass_capture(e_render_pass.SHADOWS, render_surface_shadows)
		return 0
	}

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
	
	render_shadow_cache_update(lightlist, sunout)

	// Initialize targets
	render_surface_shadows = surface_require(render_surface_shadows, render_width, render_height, false, e_surface_format.rgba32float)
	render_surface_specular = surface_require(render_surface_specular, render_width, render_height, false, e_surface_format.rgba32float)
	render_surface_hdr[0] = surface_require(render_surface_hdr[0], render_width, render_height, true, e_surface_format.rgba32float)
	render_surface_hdr[1] = surface_require(render_surface_hdr[1], render_width, render_height, true, e_surface_format.rgba32float)
	resultsurftemp = render_surface_hdr[0]
	specresultsurftemp = render_surface_hdr[1]
	
	surface_set_target(render_surface_shadows)
	{
		draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()
	
	aa_matrix = aa_jitter_matrix
	
	#region Sun
	
	if (sunout)
	{
		var angle = vec3_normalize(app.background_sun_direction)
		var sunangularradius = tan(degtorad(min(background_sunlight_angle, 179)) * .5) * project_render_shadows_blur_size
		var referenceangularradius = tan(degtorad(.526) * .5)
		render_sun_shadow_scale = (sunangularradius / referenceangularradius) * .5

		// Jitter sun direction
		if (project_render_shadows_jittered && render_sample_current > 1)
		{
			var reference = abs(angle[Z]) < .999 ? vec3(0, 0, 1) : vec3(0, 1, 0)
			var tangent = vec3_normalize(vec3_cross(reference, angle))
			var bitangent = vec3_cross(angle, tangent)
			var diskangle = random(pi * 2)
			var diskradius = sunangularradius * sqrt(random(1))
			var diskoffset = vec3_add(vec3_mul(tangent, cos(diskangle) * diskradius), vec3_mul(bitangent, sin(diskangle) * diskradius))
			angle = vec3_normalize(vec3_add(angle, diskoffset))
		}
		
		// Depth
		cam_far = cam_far_prev
		aa_matrix = MAT_IDENTITY
		render_alpha_hash = render_alpha_hash_shadows
		render_alpha_hash_force = true
		
		render_update_cascades(angle)
		
		for (var i = 0; i < render_cascades_count; i++)
		{
			var sunkey = "sun" + string(i)
			if (render_shadow_cache_enabled)
				render_surface_sun_buffer[i] = render_shadow_cache_surface(sunkey, project_render_shadows_sun_buffer_size, project_render_shadows_sun_buffer_size)
			else
				render_surface_sun_buffer[i] = surface_require(render_surface_sun_buffer[i], project_render_shadows_sun_buffer_size, project_render_shadows_sun_buffer_size, true, e_surface_format.r32float)

			if (render_shadow_cache_enabled && ds_map_exists(render_shadow_cache_ready, sunkey))
			{
				render_world_start_sun(i)
				render_world_done()
				continue
			}
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
			if (render_shadow_cache_enabled)
				render_shadow_cache_ready[?sunkey] = true
		}
		
		aa_matrix = aa_jitter_matrix
		render_alpha_hash = render_alpha_hash_allowed && app.project_render_alpha_mode
		render_alpha_hash_force = false
		
		surface_set_target_ext(0, resultsurftemp)
		surface_set_target_ext(1, specresultsurftemp)
		{
			draw_clear(c_black)
			render_world_start()
			render_world(e_render_mode.HIGH_LIGHT_SUN)
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
	}
	
	#endregion
	
	#region User-placed lights
	
	for (var i = 0; i < array_length(lightlist); i++)
	{
		with (lightlist[i])
		{
			if (!value_inherit[e_value.VISIBLE] || hide || (render_view_current.render && hq_hiding) || (!render_view_current.render && lq_hiding))
				continue
			
			if (app.project_render_shadows_jittered && render_sample_current > 1)
			{
				var xyang, zang, dis;
				xyang = random(360)
				zang = random_range(-180, 180)
				dis = value[e_value.LIGHT_SIZE] * app.project_render_shadows_blur_size / 2
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
				var pointkey = "point:" + save_id
				if (render_shadow_cache_enabled)
					render_surface_point_atlas_buffer = render_shadow_cache_surface(pointkey, atlassize * 3, atlassize * 2)
				else
					render_surface_point_atlas_buffer = surface_require(render_surface_point_atlas_buffer, atlassize * 3, atlassize * 2, true, e_surface_format.r32float)
				var pointcached = render_shadow_cache_enabled && ds_map_exists(render_shadow_cache_ready, pointkey)
				if (!pointcached)
					render_surface_point_buffer = surface_require(render_surface_point_buffer, atlassize, atlassize, true, e_surface_format.r32float)
				
				aa_matrix = MAT_IDENTITY
				render_alpha_hash = render_alpha_hash_shadows
				render_alpha_hash_force = true
				
				// Depth
				if (!pointcached)
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
				if (render_shadow_cache_enabled && !pointcached)
					render_shadow_cache_ready[?pointkey] = true
				// Restore light uniforms when the atlas was reused
				if (pointcached)
				{
					render_world_start_light(world_pos, point3D_add(world_pos, dir_get_vec3(e_dir.amount - 1)), sampleoffset, id)
					render_world_done()
				}
				
				aa_matrix = aa_jitter_matrix
				render_alpha_hash = render_alpha_hash_allowed && app.project_render_alpha_mode
				render_alpha_hash_force = false
				
				// Shadows
				with (app)
				{
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
				
				aa_matrix = MAT_IDENTITY
				render_alpha_hash = render_alpha_hash_shadows
				render_alpha_hash_force = true
				
				// Depth
				var spotkey = "spot:" + save_id
				if (render_shadow_cache_enabled)
					render_surface_spot_buffer = render_shadow_cache_surface(spotkey, app.project_render_shadows_spot_buffer_size, app.project_render_shadows_spot_buffer_size)
				else
					render_surface_spot_buffer = surface_require(render_surface_spot_buffer, app.project_render_shadows_spot_buffer_size, app.project_render_shadows_spot_buffer_size, true, e_surface_format.r32float)
				if (!render_shadow_cache_enabled || !ds_map_exists(render_shadow_cache_ready, spotkey))
				{
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
					if (render_shadow_cache_enabled)
						render_shadow_cache_ready[?spotkey] = true
				}
				else
				{
					render_world_start_light(world_pos, lookat, sampleoffset, id)
					render_world_done()
				}
				
				aa_matrix = aa_jitter_matrix
				render_alpha_hash = render_alpha_hash_allowed && app.project_render_alpha_mode
				render_alpha_hash_force = false
				
				// Shadows
				with (app)
				{
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
			
			// Add diffuse/specular
			gpu_set_blendmode(bm_add)
			
			surface_set_target(render_surface_shadows)
			{
				draw_surface_exists(resultsurftemp, 0, 0)
			}
			surface_reset_target()
			
			surface_set_target(render_surface_specular)
			{
				draw_surface_exists(specresultsurftemp, 0, 0)
			}
			
			surface_reset_target()
			
			gpu_set_blendmode(bm_normal)
		}
	}
	
	#endregion
	
	// Render shadowless point lights
	render_high_shadows_shadowless()
	
	// Apply subsurface scattering
	if (project_render_subsurface_samples > 0)
		render_high_subsurface_scatter()
	
	render_pass_capture(e_render_pass.SHADOWS, render_surface_shadows)

	if (render_shadow_pass_cache_enabled)
	{
		render_surface_shadows_cache = surface_require(render_surface_shadows_cache, render_width, render_height, false, e_surface_format.rgba32float)
		render_surface_specular_shadows = surface_require(render_surface_specular_shadows, render_width, render_height, false, e_surface_format.rgba32float)
		render_high_copy_shadow_surface(render_surface_shadows_cache, render_surface_shadows)
		render_high_copy_shadow_surface(render_surface_specular_shadows, render_surface_specular)
		render_shadow_pass_cache_ready = true
	}
}
