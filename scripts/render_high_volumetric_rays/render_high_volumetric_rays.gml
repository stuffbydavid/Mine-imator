/// render_high_volumetric_rays(basesurf, export)
/// @arg basesurf
/// @arg export

var prevsurf, export, sampleoffset, framesamples, depthsurf, resultsurf;
prevsurf = argument0
export = argument1
sampleoffset = vec3(0)

if (render_samples < setting_render_shadows_samples || render_shadows_clear || export)
{
	if (export)
	{
		framesamples = setting_render_shadows_samples
		render_samples = framesamples
	}
	else
		framesamples = 1
	
	// Render whole world for depth, but only store a limited range
	render_surface[0] = surface_require(render_surface[0], render_width, render_height, true, true)
	depthsurf = render_surface[0]
	surface_set_target(depthsurf)
	{
		draw_clear_alpha(c_white, background_volumetric_rays_sky)
		render_world_start()
		proj_depth_far = max(2000, background_sunlight_range)
		render_world(e_render_mode.DEPTH_NO_SKY)
		render_world_done()
	}
	surface_reset_target()
	
	for (var s = 0; s < framesamples; s++)
	{
		// Render sun depth buffer
		if (export)
		{
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
			
			// Depth
			render_surface_sun_buffer = surface_require(render_surface_sun_buffer, setting_render_shadows_sun_buffer_size, setting_render_shadows_sun_buffer_size, true)
			surface_set_target(render_surface_sun_buffer)
			{
				draw_clear(c_white)
				render_world_start_sun(
					point3D(background_light_data[0] + sampleoffset[X], background_light_data[1] + sampleoffset[Y], background_light_data[2] + sampleoffset[Z]), 
					point3D(cam_from[X] * background_sunlight_follow, cam_from[Y] * background_sunlight_follow, 0))
				render_world(e_render_mode.HIGH_LIGHT_SUN_DEPTH)
				render_world_done()
			}
			surface_reset_target()
		}
		
		// Render and apply volumetric rays
		var exptemp, dectemp, resultsurftemp;
		render_surface_sun_volume_expo = surface_require(render_surface_sun_volume_expo, render_width, render_height)
		render_surface_sun_volume_dec = surface_require(render_surface_sun_volume_dec, render_width, render_height)
		render_surface[1] = surface_require(render_surface[1], render_width, render_height)
		resultsurftemp = render_surface[1]
		
		surface_set_target(resultsurftemp)
		{
			draw_clear_alpha(c_black, 1)
			render_shader_obj = shader_map[?shader_high_volumetric_rays]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_volumetric_rays_set(depthsurf, render_surface_sun_buffer)
			}
			draw_blank(0, 0, render_width, render_height)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()

		render_surface[2] = surface_require(render_surface[2], render_width, render_height, true, true)
		render_surface[3] = surface_require(render_surface[3], render_width, render_height, true, true)
		exptemp = render_surface[2]
		dectemp = render_surface[3]

		// Draw temporary exponent surface
		surface_set_target(exptemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_sun_volume_expo, 0, 0)
		
			if ((export && s = 0) || render_shadows_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()

		surface_set_target(dectemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_sun_volume_dec, 0, 0)
		
			if ((export && s = 0) || render_shadows_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()

		// Add light shadow to buffer
		surface_set_target_ext(0, render_surface_sun_volume_expo)
		surface_set_target_ext(1, render_surface_sun_volume_dec)
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
}

// Render directly to target?
resultsurf = render_high_get_apply_surf()

// Add to shadows
surface_set_target(resultsurf)
{
	draw_clear_alpha(c_black, 0)
	
	draw_surface_exists(prevsurf, 0, 0)
	
	// Screen blend mode
	gpu_set_blendmode_ext_sepalpha(bm_one, bm_inv_src_color, bm_dest_alpha, bm_one)
	
	render_shader_obj = shader_map[?shader_high_shadows_unpack]
	with (render_shader_obj)
	{
		shader_set(shader)
		shader_high_shadows_unpack_set(render_surface_sun_volume_expo, render_surface_sun_volume_dec, render_samples)
	}
	draw_blank(0, 0, render_width, render_height)
	with (render_shader_obj)
		shader_clear()
	
	gpu_set_blendmode(bm_normal)
}
surface_reset_target()

if (export)
{
	surface_free(render_surface_sun_volume_expo)
	surface_free(render_surface_sun_volume_dec)
	surface_free(render_surface_sun_buffer)
}

return resultsurf
