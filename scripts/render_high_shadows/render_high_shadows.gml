/// render_high_shadows(export)
/// @arg export

var export, resultsurftemp, sampleoffset, sunout, samplestart, sampleend, lightlist;
export = argument0
sampleoffset = point3D(0, 0, 0)
sunout = (background_sunlight_color_final != c_black)
samplestart = 0
sampleend = 0
lightlist = array()

// Set samples to setting
if (!export)
{
	// Check for changes to shadows
	if (render_samples = -1 || !surface_exists(render_surface_sun_shadows_expo) || (!array_equals(render_shadows_matrix, view_proj_matrix)) || (render_shadows_size[X] != render_width) || (render_shadows_size[Y] != render_height))
	{
		render_shadows_matrix = array_copy_1d(view_proj_matrix)
		render_shadows_size = point2D(render_width, render_height)
		render_samples = 0
		render_shadows_clear = true
	}
	
	if (render_samples >= setting_render_shadows_samples)
		return 0
	
	samplestart = render_samples
	sampleend = render_samples + 1
	
	render_samples++
}
else
{
	samplestart = 0
	sampleend = setting_render_shadows_samples
	render_samples = setting_render_shadows_samples
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

// Create initial shadow surface from sun
render_surface_shadows = surface_require(render_surface_shadows, render_width, render_height, true)

#region Sun

for (var s = samplestart; s < sampleend; s++)
{
	if (sunout)
	{
		// Scatter position
		if (s > 1)
		{
			random_set_seed(s)
	
			var xyang, zang, dis;
			xyang = random(360)
			zang = random_range(-180, 180)
			dis = ((background_sunlight_angle * (world_size / 2)) / 57.2958)
			dis = random_range(-dis/2, dis/2)
			sampleoffset[X] = lengthdir_x(dis, xyang) * lengthdir_x(1, zang)
			sampleoffset[Y] = lengthdir_y(dis, xyang) * lengthdir_x(1, zang)
			sampleoffset[Z] = lengthdir_z(dis, zang)
		}
	
		// Update camera (position) if not previously initialized
		render_world_start()
	
		// Depth
		render_surface_sun_buffer = surface_require(render_surface_sun_buffer, setting_render_shadows_sun_buffer_size, setting_render_shadows_sun_buffer_size, true)
		surface_set_target(render_surface_sun_buffer)
		{
			gpu_set_blendmode_ext(bm_one, bm_zero)
			
			draw_clear(c_white)
			render_world_start_sun(
				point3D(background_light_data[0] + sampleoffset[X], background_light_data[1] + sampleoffset[Y], background_light_data[2] + sampleoffset[Z]), 
				point3D(cam_from[X] * background_sunlight_follow, cam_from[Y] * background_sunlight_follow, 0))
			render_world(e_render_mode.HIGH_LIGHT_SUN_DEPTH)
			render_world_done()
			
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
	
		// Color
		if (setting_render_shadows_sun_colored)
		{
			render_surface_sun_color_buffer = surface_require(render_surface_sun_color_buffer, setting_render_shadows_sun_buffer_size, setting_render_shadows_sun_buffer_size, true)
			surface_set_target(render_surface_sun_color_buffer)
			{
				draw_clear(c_white)
				render_world_start_sun(
					point3D(background_light_data[0] + sampleoffset[X], background_light_data[1] + sampleoffset[Y], background_light_data[2] + sampleoffset[Z]), 
					point3D(cam_from[X] * background_sunlight_follow, cam_from[Y] * background_sunlight_follow, 0))
				render_world(e_render_mode.HIGH_LIGHT_SUN_COLOR)
				render_world_done()
			}
			surface_reset_target()
		}
	}

	render_surface[2] = surface_require(render_surface[2], render_width, render_height, true)
	resultsurftemp = render_surface[2]

	surface_set_target(resultsurftemp)
	{
		draw_clear(c_black)
		render_world_start()
		render_world(sunout ? e_render_mode.HIGH_LIGHT_SUN : e_render_mode.HIGH_LIGHT_NIGHT)
		render_world_done()
	}
	surface_reset_target()

	var exptemp, dectemp;
	render_surface_sun_shadows_expo = surface_require(render_surface_sun_shadows_expo, render_width, render_height)
	render_surface_sun_shadows_dec = surface_require(render_surface_sun_shadows_dec, render_width, render_height)
	render_surface[3] = surface_require(render_surface[3], render_width, render_height, true, true)
	render_surface[4] = surface_require(render_surface[4], render_width, render_height, true, true)
	exptemp = render_surface[3]
	dectemp = render_surface[4]
	
	// Draw temporary exponent surface
	surface_set_target(exptemp)
	{
		draw_clear_alpha(c_black, 1)
		draw_surface_exists(render_surface_sun_shadows_expo, 0, 0)
		
		if (s = 0 || render_shadows_clear)
			draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()

	surface_set_target(dectemp)
	{
		draw_clear_alpha(c_black, 1)
		draw_surface_exists(render_surface_sun_shadows_dec, 0, 0)
		
		if (s = 0 || render_shadows_clear)
			draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()

	// Add light shadow to buffer
	surface_set_target_ext(0, render_surface_sun_shadows_expo)
	surface_set_target_ext(1, render_surface_sun_shadows_dec)
	{
		render_shader_obj = shader_map[?shader_high_shadows_add]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_shadows_add_set(exptemp, dectemp)
		}
		draw_surface_exists(resultsurftemp, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
}

// Add to shadows
surface_set_target(render_surface_shadows)
{
	draw_clear_alpha(c_black, 1)
	gpu_set_blendmode(bm_add)
	
	render_shader_obj = shader_map[?shader_high_shadows_unpack]
	with (render_shader_obj)
	{
		shader_set(shader)
		shader_high_shadows_unpack_set(render_surface_sun_shadows_expo, render_surface_sun_shadows_dec, render_samples)
	}
	draw_blank(0, 0, render_width, render_height)
	with (render_shader_obj)
		shader_clear()
	
	gpu_set_blendmode(bm_normal)
}
surface_reset_target()

// Free surfaces
if (export)
{
	surface_free(render_surface_sun_shadows_expo)
	surface_free(render_surface_sun_shadows_dec)
	surface_free(render_surface_sun_buffer)
	surface_free(render_surface_sun_color_buffer)
}

#endregion

// Get number of lights (to divide brightness by)
render_light_amount = array_length_1d(lightlist) + ds_list_size(render_shadowless_point_list)

#region User placed lights

for (var i = 0; i < array_length_1d(lightlist); i++)
{
	with (lightlist[i])
	{
		for (var s = samplestart; s < sampleend; s++)
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
				dis = random_range(-value[e_value.LIGHT_SIZE]/2, value[e_value.LIGHT_SIZE]/2)
				sampleoffset[X] = lengthdir_x(dis, xyang) * lengthdir_x(1, zang)
				sampleoffset[Y] = lengthdir_y(dis, xyang) * lengthdir_x(1, zang)
				sampleoffset[Z] = lengthdir_z(dis, zang)
			}
	
			if (type = e_tl_type.POINT_LIGHT)
			{
				// If shadowless, add to shadowless point light list and continue
				if (!shadows)
				{
					ds_list_add(render_shadowless_point_list, id)
					continue
				}
		
				// Depth
				for (var d = e_dir.EAST; d < e_dir.amount; d++)
				{
					var look = dir_get_vec3(d);
					if (d = e_dir.DOWN || d = e_dir.UP)
						look[Y] -= 0.0001
			
					render_surface_point_buffer[d] = surface_require(render_surface_point_buffer[d], app.setting_render_shadows_point_buffer_size, app.setting_render_shadows_point_buffer_size, true)
					surface_set_target(render_surface_point_buffer[d])
					{
						gpu_set_blendmode_ext(bm_one, bm_zero)
						
						draw_clear(c_white)
						render_world_start_light(point3D_add(world_pos, sampleoffset), point3D_add(point3D_add(world_pos, sampleoffset), look), 1, value[e_value.LIGHT_RANGE], 90, value[e_value.LIGHT_COLOR], value[e_value.LIGHT_STRENGTH], value[e_value.LIGHT_FADE_SIZE])
						render_world(e_render_mode.HIGH_LIGHT_POINT_DEPTH)
				
						render_world_done()
						
						gpu_set_blendmode(bm_normal)
					}
					surface_reset_target()
				}
		
				// Shadows
				with (app)
				{
					render_surface[2] = surface_require(render_surface[2], render_width, render_height, true)
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
			else if (type = e_tl_type.SPOT_LIGHT)
			{
				var lookat = point3D_mul_matrix(point3D(0.0001, 1, 0), matrix);
			
				// Depth
				render_surface_spot_buffer = surface_require(render_surface_spot_buffer, app.setting_render_shadows_spot_buffer_size, app.setting_render_shadows_spot_buffer_size, true)
				surface_set_target(render_surface_spot_buffer)
				{
					gpu_set_blendmode_ext(bm_one, bm_zero)
					
					draw_clear(c_white)
			
					render_world_start_light(point3D_add(world_pos, sampleoffset), point3D_add(lookat, sampleoffset), 1, value[e_value.LIGHT_RANGE], value[e_value.LIGHT_SPOT_RADIUS], value[e_value.LIGHT_COLOR], value[e_value.LIGHT_STRENGTH], value[e_value.LIGHT_FADE_SIZE], value[e_value.LIGHT_SPOT_SHARPNESS])
			
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
					render_surface[2] = surface_require(render_surface[2], render_width, render_height, true)
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
	
			// Add to timeline shadow buffer
			var exptemp, dectemp;
			light_shadows_exponent_surf = surface_require(light_shadows_exponent_surf, render_width, render_height)
			light_shadows_decimal_surf = surface_require(light_shadows_decimal_surf, render_width, render_height)
			render_surface[3] = surface_require(render_surface[3], render_width, render_height, true, true)
			render_surface[4] = surface_require(render_surface[4], render_width, render_height, true, true)
			exptemp = render_surface[3]
			dectemp = render_surface[4]
	
			// Draw temporary exponent surface
			surface_set_target(exptemp)
			{
				draw_clear_alpha(c_black, 1)
				draw_surface_exists(light_shadows_exponent_surf, 0, 0)
		
				if (s = 0 || render_shadows_clear)
					draw_clear_alpha(c_black, 1)
			}
			surface_reset_target()

			surface_set_target(dectemp)
			{
				draw_clear_alpha(c_black, 1)
				draw_surface_exists(light_shadows_decimal_surf, 0, 0)
		
				if (s = 0 || render_shadows_clear)
					draw_clear_alpha(c_black, 1)
			}
			surface_reset_target()
	
			// Add light shadow to buffer
			surface_set_target_ext(0, light_shadows_exponent_surf)
			surface_set_target_ext(1, light_shadows_decimal_surf)
			{
				render_shader_obj = shader_map[?shader_high_shadows_add]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_high_shadows_add_set(exptemp, dectemp)
				}
				draw_surface_exists(resultsurftemp, 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()	
		}
		
		// Add to shadows
		surface_set_target(render_surface_shadows)
		{
			gpu_set_blendmode(bm_add)
		
			render_shader_obj = shader_map[?shader_high_shadows_unpack]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_shadows_unpack_set(other.light_shadows_exponent_surf, other.light_shadows_decimal_surf, render_samples)
			}
			draw_blank(0, 0, render_width, render_height)
			with (render_shader_obj)
				shader_clear()
		
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		
		// Free surfaces
		if (export)
		{
			surface_free(light_shadows_exponent_surf)
			surface_free(light_shadows_decimal_surf)
		}
	}
}

#endregion

#region Shadowless point lights
if (ds_list_size(render_shadowless_point_list) > 0)
{
	var resultsurftemp, remaininglights, groupsdone;
	remaininglights = ds_list_size(render_shadowless_point_list)
	groupsdone = 0
	while (remaininglights > 0)
	{
		for (var l = 0; l < 63; l++)
		{
			if (remaininglights = 0)
				continue
				
			var light = render_shadowless_point_list[| l + (groupsdone * 63)];
			
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 0] = light.world_pos[X]
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 1] = light.world_pos[Y]
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 2] = light.world_pos[Z]
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 3] = light.value[e_value.LIGHT_RANGE]
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 4] = (color_get_red(light.value[e_value.LIGHT_COLOR]) / 255) * light.value[e_value.LIGHT_STRENGTH]
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 5] = (color_get_green(light.value[e_value.LIGHT_COLOR]) / 255) * light.value[e_value.LIGHT_STRENGTH]
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 6] = (color_get_blue(light.value[e_value.LIGHT_COLOR]) / 255) * light.value[e_value.LIGHT_STRENGTH]
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 7] = light.value[e_value.LIGHT_FADE_SIZE]
			render_shadowless_point_amount++
			remaininglights--
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
		if (surface_exists(render_surface_shadows))
		{
			surface_set_target(render_surface_shadows)
			{
				gpu_set_blendmode(bm_add)
				draw_surface_exists(resultsurftemp, 0, 0)
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
		}
		groupsdone++
		render_shadowless_point_amount = 0
	}
	
	ds_list_clear(render_shadowless_point_list)
}
#endregion
