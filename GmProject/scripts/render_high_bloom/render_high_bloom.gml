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
	
	var bladeamount = max(1, render_camera.value[e_value.CAM_BLADE_AMOUNT]);
	var streaks = (bladeamount mod 2 = 0) ? bladeamount / 2 : bladeamount;
	
	if (render_camera.value[e_value.CAM_BLOOM_RATIO] > 0)
	{
		var bladeangle = degtorad(render_camera.value[e_value.CAM_BLADE_ANGLE]);
		
		for (var b = 0; b < streaks; b++)
		{
			var bladerot = degtorad((180 / streaks) * b) + bladeangle;
			var totalweight = render_blur_pyramid(thresholdsurf, baseradius, levelweight, hdr, 5, cos(bladerot), sin(bladerot), 4);
			bloomstrength = (1 / streaks * render_camera.value[e_value.CAM_BLOOM_RATIO] * render_camera.value[e_value.CAM_BLOOM_INTENSITY]) / totalweight
			
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
					shader_add_set(render_surface_blur[0], bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND], 1, baseradius > 0)
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
						shader_add_set(render_surface_blur[0], bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND], 1, baseradius > 0)
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
		var totalweight = render_blur_pyramid(thresholdsurf, baseradius, levelweight, hdr);
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
				shader_add_set(render_surface_blur[0], bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND], 1, baseradius > 0)
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
					shader_add_set(render_surface_blur[0], bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND], 1, baseradius > 0)
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
