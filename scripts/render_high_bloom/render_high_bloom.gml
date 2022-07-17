/// render_high_bloom(basesurf)
/// @arg basesurf

function render_high_bloom(prevsurf)
{
	var thresholdsurf, bloomsurf, bloomsurftemp, resultsurf, baseradius, bloomstrength;
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	thresholdsurf = render_surface[0]
	bloomsurf = render_surface[1]
	bloomsurftemp = render_surface[2]
	resultsurf = render_high_get_apply_surf()
	baseradius = ((render_camera.value[e_value.CAM_BLOOM_RADIUS] * 10) * render_height / 500)
	bloomstrength = 1
	
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
			
			surface_set_target(bloomsurftemp)
			{
				draw_surface_exists(thresholdsurf, 0, 0)
			}
			surface_reset_target()
			
			// 3-pass 9-tap guassian blur
			for (var i = 0; i < 3; i++)
			{
				surface_set_target(bloomsurf)
				{
					render_shader_obj = shader_map[?shader_blur]
					with (render_shader_obj)
					{
						shader_set(shader)
						shader_blur_set(render_blur_kernel, baseradius / (1 + 1.333 * i), cos(bladerot), sin(bladerot))
					}
					draw_surface_exists(bloomsurftemp, 0, 0)
					with (render_shader_obj)
						shader_clear()
				}
				surface_reset_target()
			
				surface_set_target(bloomsurftemp)
				{
					draw_surface_exists(bloomsurf, 0, 0)
				}
				surface_reset_target()
			}
			
			bloomstrength = (1/blades * render_camera.value[e_value.CAM_BLOOM_RATIO] * render_camera.value[e_value.CAM_BLOOM_INTENSITY])
			
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
					shader_add_set(bloomsurf, bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND])
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
						shader_add_set(bloomsurf, bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND])
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
		surface_set_target(bloomsurftemp)
		{
			draw_surface_exists(thresholdsurf, 0, 0)
		}
		surface_reset_target()
		
		// 3-pass 9-tap guassian blur
		for (var i = 0; i < 3; i++)
		{
			surface_set_target(bloomsurf)
			{
				render_shader_obj = shader_map[?shader_blur]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_blur_set(render_blur_kernel, baseradius / (1 + 1.333 * i), 1, 0)
				}
				draw_surface_exists(bloomsurftemp, 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
			
			surface_set_target(bloomsurftemp)
			{
				render_shader_obj = shader_map[?shader_blur]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_blur_set(render_blur_kernel, baseradius / (1 + 1.333 * i), 0, 1)
				}
				draw_surface_exists(bloomsurf, 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
		}
		
		bloomstrength = ((1.0 - render_camera.value[e_value.CAM_BLOOM_RATIO]) * render_camera.value[e_value.CAM_BLOOM_INTENSITY])
		
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
				shader_add_set(bloomsurf, bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND])
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
					shader_add_set(bloomsurf, bloomstrength, render_camera.value[e_value.CAM_BLOOM_BLEND])
				}
				draw_surface_exists(bloomsurftemp, 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
		}
	}
	
	#endregion
	
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface(prevsurf, 0, 0)
	}
	surface_reset_target()
	
	return resultsurf
}
