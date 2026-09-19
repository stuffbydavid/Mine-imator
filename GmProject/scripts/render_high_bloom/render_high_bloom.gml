/// render_high_bloom(basesurf)
/// @arg basesurf

function render_high_bloom(prevsurf, hdr = false)
{
	var thresholdsurf, bloomsurftemp, resultsurf, baseradius, bloomstrength;
	if (hdr)
	{
		render_surface_hdr_post[0] = surface_require(render_surface_hdr_post[0], render_width, render_height, false, e_surface_format.rgba32float)
		render_surface_hdr_post[2] = surface_require(render_surface_hdr_post[2], render_width, render_height, false, e_surface_format.rgba32float)
	}
	else
	{
		render_surface[0] = surface_require(render_surface[0], render_width, render_height)
		render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	}
	thresholdsurf = hdr ? render_surface_hdr_post[0] : render_surface[0]
	bloomsurftemp = hdr ? render_surface_hdr_post[2] : render_surface[2]
	resultsurf = render_high_get_apply_surf(hdr)
	baseradius = ((render_camera.value[e_value.CAM_BLOOM_RADIUS] * 10) * render_height / 500)
	bloomstrength = 1
	var levelweight = clamp(0.5 + render_camera.value[e_value.CAM_BLOOM_RADIUS], 0.5, 2.75);
	gpu_set_tex_repeat(false)
	var captureblur = render_pass = e_render_pass.BLOOM_BLUR || render_pass = e_render_pass.ALL;
	if (captureblur)
	{
		gpu_set_blendmode_ext(bm_one, bm_zero)
		surface_set_target(resultsurf)
		{
			draw_surface_exists(prevsurf, 0, 0)
		}
		surface_reset_target()
		if (!hdr)
			gpu_set_blendmode(bm_normal)
	}
	
	// Filter colors to blur
	surface_set_target(thresholdsurf)
	{
		draw_clear_alpha(c_black, 1)
		
		render_shader_obj = shader_map[?shader_high_bloom_threshold]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_bloom_threshold_set()
		}
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	render_pass_capture(e_render_pass.BLOOM_THRESHOLD, thresholdsurf)
	if (hdr)
		gpu_set_blendmode_ext(bm_one, bm_zero)
	
	#region Bloom streaks
	
	var blades, bladerot, bladeangle;
	blades = max(1, render_camera.value[e_value.CAM_BLADE_AMOUNT] / 2)
	blades = frac(blades) > 0 ? render_camera.value[e_value.CAM_BLADE_AMOUNT] : blades
	
	if (render_camera.value[e_value.CAM_BLOOM_RATIO] > 0 && blades)
	{
		bladeangle = ((pi * 2) / (360 / render_camera.value[e_value.CAM_BLADE_ANGLE]))
		
		for (var b = 0; b < blades; b++)
		{
			bladerot = degtorad((180 / blades) * b) + bladeangle
			
			// Downsample and blur along this blade at several scales
			var downsource = thresholdsurf;
			for (var i = 0; i < 5; i++)
			{
				var scale = power(2, i + 1);
				var levelwidth = max(1, ceil(render_width / scale));
				var levelheight = max(1, ceil(render_height / scale));
				var format = hdr ? e_surface_format.rgba32float : e_surface_format.rgba8unorm;
				render_surface_blur[i] = surface_require(render_surface_blur[i], levelwidth, levelheight, false, format)
				render_surface_blur_temp[i] = surface_require(render_surface_blur_temp[i], levelwidth, levelheight, false, format)

				gpu_set_texfilter(true)
				surface_set_target(render_surface_blur[i])
				{
					draw_clear_alpha(c_black, 0)
					draw_surface_size(downsource, 0, 0, levelwidth, levelheight)
				}
				surface_reset_target()
				gpu_set_texfilter(false)

				surface_set_target(render_surface_blur_temp[i])
				{
					render_shader_obj = shader_map[?shader_blur]
					with (render_shader_obj)
					{
						shader_set(shader)
						shader_blur_set(render_blur_kernel, baseradius * scale / 4, cos(bladerot), sin(bladerot), true)
					}
					draw_surface_exists(render_surface_blur[i], 0, 0)
					with (render_shader_obj)
						shader_clear()
				}
				surface_reset_target()

				downsource = render_surface_blur_temp[i]
			}
			surface_set_target(render_surface_blur[4])
			{
				draw_surface_exists(render_surface_blur_temp[4], 0, 0)
			}
			surface_reset_target()

			for (var i = 3; i >= 0; i--)
			{
				surface_set_target(render_surface_blur[i])
				{
					render_shader_obj = shader_map[?shader_add]
					with (render_shader_obj)
					{
						shader_set(shader)
						shader_add_set(render_surface_blur[i + 1], levelweight, c_white, 1, true)
					}
					draw_surface_exists(render_surface_blur_temp[i], 0, 0)
					with (render_shader_obj)
						shader_clear()
				}
				surface_reset_target()
			}

			var totalweight = 0;
			for (var i = 0; i < 5; i++)
				totalweight += power(levelweight, i)
			bloomstrength = (1/blades * render_camera.value[e_value.CAM_BLOOM_RATIO] * render_camera.value[e_value.CAM_BLOOM_INTENSITY]) / totalweight
			
			surface_set_target(bloomsurftemp)
			{
				draw_clear_alpha(c_black, 0)
				draw_surface(prevsurf, 0, 0)
			}
			surface_reset_target()
			
			// Add to result
			surface_set_target(prevsurf)
			{
				draw_clear_alpha(c_black, 0)
				
				render_shader_obj = shader_map[?shader_add]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_add_set(render_surface_blur[0], bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND], 1, true)
				}
				draw_surface_exists(bloomsurftemp, 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
			
			// Add to lens dirt
			if (render_camera_lens_dirt_bloom)
			{
				surface_set_target(bloomsurftemp)
				{
					draw_clear_alpha(c_black, 0)
					draw_surface(render_surface_lens, 0, 0)
				}
				surface_reset_target()
				
				surface_set_target(render_surface_lens)
				{
					render_shader_obj = shader_map[?shader_add]
					with (render_shader_obj)
					{
						shader_set(shader)
						shader_add_set(render_surface_blur[0], bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND], 1, true)
					}
					draw_surface_exists(bloomsurftemp, 0, 0)
					with (render_shader_obj)
						shader_clear()
				}
				surface_reset_target()
			}
		}
	}
	
	#endregion
	
	#region Bloom
	
	if (render_camera.value[e_value.CAM_BLOOM_RATIO] < 1)
	{
		// Each level keeps a similar blur radius in its own pixels
		var downsource = thresholdsurf;
		for (var i = 0; i < 6; i++)
		{
			var scale = power(2, i + 1);
			var levelwidth = max(1, ceil(render_width / scale));
			var levelheight = max(1, ceil(render_height / scale));
			var format = hdr ? e_surface_format.rgba32float : e_surface_format.rgba8unorm;
			render_surface_blur[i] = surface_require(render_surface_blur[i], levelwidth, levelheight, false, format)
			render_surface_blur_temp[i] = surface_require(render_surface_blur_temp[i], levelwidth, levelheight, false, format)

			gpu_set_texfilter(true)
			surface_set_target(render_surface_blur[i])
			{
				draw_clear_alpha(c_black, 0)
				draw_surface_size(downsource, 0, 0, levelwidth, levelheight)
			}
			surface_reset_target()
			gpu_set_texfilter(false)

			var radius = baseradius * scale / 8;
			surface_set_target(render_surface_blur_temp[i])
			{
				render_shader_obj = shader_map[?shader_blur]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_blur_set(render_blur_kernel, radius, 1, 0, true)
				}
				draw_surface_exists(render_surface_blur[i], 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()

			surface_set_target(render_surface_blur[i])
			{
				render_shader_obj = shader_map[?shader_blur]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_blur_set(render_blur_kernel, radius, 0, 1, true)
				}
				draw_surface_exists(render_surface_blur_temp[i], 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()

			downsource = render_surface_blur[i]
		}

		// Give the wider halo enough weight to remain visible around small highlights
		for (var i = 4; i >= 0; i--)
		{
			surface_set_target(render_surface_blur_temp[i])
			{
				render_shader_obj = shader_map[?shader_add]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_add_set(render_surface_blur[i + 1], levelweight, c_white, 1, true)
				}
				draw_surface_exists(render_surface_blur[i], 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()

			surface_set_target(render_surface_blur[i])
			{
				draw_surface_exists(render_surface_blur_temp[i], 0, 0)
			}
			surface_reset_target()
		}
		
		var totalweight = 0;
		for (var i = 0; i < 6; i++)
			totalweight += power(levelweight, i)
		bloomstrength = ((1.0 - render_camera.value[e_value.CAM_BLOOM_RATIO]) * render_camera.value[e_value.CAM_BLOOM_INTENSITY]) / totalweight
		
		surface_set_target(bloomsurftemp)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface(prevsurf, 0, 0)
		}
		surface_reset_target()
		
		// Add to result
		surface_set_target(prevsurf)
		{
			draw_clear_alpha(c_black, 0)
			
			render_shader_obj = shader_map[?shader_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_add_set(render_surface_blur[0], bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND], 1, true)
			}
			draw_surface_exists(bloomsurftemp, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
		
		// Add to lens dirt
		if (render_camera_lens_dirt_bloom)
		{
			surface_set_target(bloomsurftemp)
			{
				draw_clear_alpha(c_black, 0)
				draw_surface(render_surface_lens, 0, 0)
			}
			surface_reset_target()
			
			surface_set_target(render_surface_lens)
			{
				render_shader_obj = shader_map[?shader_add]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_add_set(render_surface_blur[0], bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND], 1, true)
				}
				draw_surface_exists(bloomsurftemp, 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
		}
	}
	
	#endregion
	
	if (captureblur)
	{
		// Subtract the original scene to include both round bloom and blade streaks
		gpu_set_blendmode_ext(bm_one, bm_zero)
		surface_set_target(bloomsurftemp)
		{
			render_shader_obj = shader_map[?shader_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_add_set(resultsurf, -1)
			}
			draw_surface_exists(prevsurf, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
		if (!hdr)
			gpu_set_blendmode(bm_normal)
		render_pass_capture(e_render_pass.BLOOM_BLUR, bloomsurftemp)
		if (hdr)
			gpu_set_blendmode_ext(bm_one, bm_zero)
	}

	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface(prevsurf, 0, 0)
	}
	surface_reset_target()
	gpu_set_tex_repeat(true)
	
	return resultsurf
}
