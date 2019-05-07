// render_high_shadows()

var resultsurf;

var sunout = (background_sunlight_color_final != c_black);

// Sun
if (sunout)
{
	// Depth
	render_surface_sun_buffer = surface_require(render_surface_sun_buffer, setting_render_shadows_sun_buffer_size, setting_render_shadows_sun_buffer_size)
	surface_set_target(render_surface_sun_buffer)
	{
		draw_clear(c_white)
		render_world_start_light(
			point3D(background_light_data[0], background_light_data[1], background_light_data[2]), 
			point3D(cam_from[X] * background_sunlight_follow, cam_from[Y] * background_sunlight_follow, 0), 
			background_light_data[3], background_light_data[7], 
			45, background_sunlight_color_final
		)
		render_world(e_render_mode.HIGH_LIGHT_SUN_DEPTH)
		render_world_done()
	}
	surface_reset_target()
		
}

// Create initial shadow surface from sun
render_surface[1] = surface_require(render_surface[1], render_width, render_height)
resultsurf = render_surface[1]
surface_set_target(resultsurf)
{
	draw_clear(c_white)
	render_world_start()
	render_world(test(sunout, e_render_mode.HIGH_LIGHT_SUN, e_render_mode.HIGH_LIGHT_NIGHT))
	render_world_done()
}
surface_reset_target()

// Get number of lights (to divide brightness by)
render_light_amount = 0
with (obj_timeline)
	if (value_inherit[e_value.VISIBLE] && !hide && (type = e_tl_type.POINT_LIGHT || type = e_tl_type.SPOT_LIGHT))
		render_light_amount++

// User placed lights
with (obj_timeline)
{
	var resultsurftemp;
	
	if (!value_inherit[e_value.VISIBLE] || hide || (render_view_current.render && hq_hiding) || (!render_view_current.render && lq_hiding))
		continue
		
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
			
			render_surface_point_buffer[d] = surface_require(render_surface_point_buffer[d], app.setting_render_shadows_point_buffer_size, app.setting_render_shadows_point_buffer_size)
			surface_set_target(render_surface_point_buffer[d])
			{
				draw_clear(c_white)
				render_world_start_light(world_pos, point3D_add(world_pos, look), 1, value[e_value.LIGHT_RANGE], 90, value[e_value.LIGHT_COLOR], value[e_value.LIGHT_FADE_SIZE])
				
				render_world(e_render_mode.HIGH_LIGHT_POINT_DEPTH)
				
				render_world_done()
			}
			surface_reset_target()
		}
		
		// Shadows
		with (app)
		{
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
	else if (type = e_tl_type.SPOT_LIGHT)
	{
		var lookat = point3D_mul_matrix(point3D(0.0001, 1, 0), matrix);
			
		// Depth
		render_surface_spot_buffer = surface_require(render_surface_spot_buffer, app.setting_render_shadows_spot_buffer_size, app.setting_render_shadows_spot_buffer_size)
		surface_set_target(render_surface_spot_buffer)
		{
			draw_clear(c_white)
			
			render_world_start_light(world_pos, lookat, 1, value[e_value.LIGHT_RANGE], value[e_value.LIGHT_SPOT_RADIUS], value[e_value.LIGHT_COLOR], value[e_value.LIGHT_FADE_SIZE], value[e_value.LIGHT_SPOT_SHARPNESS])
			
			// Only render depth for shadows if the light source isn't shadowless
			if (shadows)
				render_world(e_render_mode.HIGH_LIGHT_SPOT_DEPTH)
			
			render_world_done()
		}
		surface_reset_target()
		
		// Shadows
		with (app)
		{
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
	
	// Add to final shadow surface
	if (surface_exists(resultsurf))
	{
		surface_set_target(resultsurf)
		{
			gpu_set_blendmode(bm_add)
			draw_surface_exists(resultsurftemp, 0, 0)
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
	}
	
}

// Shadowless point lights
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
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 4] = color_get_red(light.value[e_value.LIGHT_COLOR]) / 255
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 5] = color_get_green(light.value[e_value.LIGHT_COLOR]) / 255
			render_shadowless_point_data[render_shadowless_point_amount * 8 + 6] = color_get_blue(light.value[e_value.LIGHT_COLOR]) / 255
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
		if (surface_exists(resultsurf))
		{
			surface_set_target(resultsurf)
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

gpu_set_texfilter(false)

return resultsurf
