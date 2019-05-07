/// render_high_bloom(basesurf)
/// @arg basesurf

var prevsurf, bloomsurf, resultsurf;
prevsurf = argument0
render_surface[0] = surface_require(render_surface[0], render_width, render_height)
bloomsurf = render_surface[0]
	
// Bloom threshold
surface_set_target(bloomsurf)
{
	draw_clear_alpha(c_black, 1)
	gpu_set_texfilter(true)
	gpu_set_texrepeat(false)
		
	render_shader_obj = shader_map[?shader_high_bloom_threshold]
	with (render_shader_obj)
	{
		shader_set(shader)
		shader_high_bloom_threshold_set()
	}
	draw_surface_exists(prevsurf, 0, 0)
	with (render_shader_obj)
		shader_clear()
			
	gpu_set_texfilter(false)
	gpu_set_texrepeat(true)
}
surface_reset_target()
	
// Blur
if (render_camera.value[e_value.CAM_BLOOM_RADIUS] > 0 && render_camera.value[e_value.CAM_BLOOM_INTENSITY] > 0)
{
	var bloomsurftemp;
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	bloomsurftemp = render_surface[1]
		
	render_shader_obj = shader_map[?shader_blur]
	with (render_shader_obj)
		shader_set(shader)
		
	// Radius changes based on the render height to make it consistant with the size of the render
	var baseradius = ((render_camera.value[e_value.CAM_BLOOM_RADIUS] * 10) * render_height / 500);
	gpu_set_tex_repeat(false)
	gpu_set_texfilter(true)

	for (var i = 0; i < 3; i++)
	{
		var radius = baseradius / (1 + 1.333 * i);

		// Horizontal
		surface_set_target(bloomsurftemp)
		{
			with (render_shader_obj)
				shader_blur_set(render_width, radius, 1 + render_camera.value[e_value.CAM_BLOOM_RATIO], 0)
			draw_surface_exists(bloomsurf, 0, 0)
		}
		surface_reset_target()
			
		// Vertical
		surface_set_target(bloomsurf)
		{
			with (render_shader_obj)
				shader_blur_set(render_height, radius, 0, 1 - render_camera.value[e_value.CAM_BLOOM_RATIO])
			draw_surface_exists(bloomsurftemp, 0, 0)
		}
		surface_reset_target()
	}
		
	with (render_shader_obj)
		shader_clear()
				
	gpu_set_tex_repeat(true)
	gpu_set_texfilter(false)
		
}
	
// Apply Bloom
resultsurf = render_high_get_apply_surf()
	
surface_set_target(resultsurf)
{
	draw_clear_alpha(c_black, 0)
		
	render_shader_obj = shader_map[?shader_add]
	with (render_shader_obj)
	{
		shader_set(shader)
		shader_add_set(bloomsurf, render_camera.value[e_value.CAM_BLOOM_INTENSITY], render_camera.value[e_value.CAM_BLOOM_BLEND])
	}
	draw_surface_exists(prevsurf, 0, 0)
	with (render_shader_obj)
		shader_clear()
}
surface_reset_target()
	
// Add to lens
if (render_camera_lens_dirt_bloom)
{
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	prevsurf = render_surface[2]
		
	surface_set_target(prevsurf)
	{
		draw_surface(render_surface_lens, 0, 0)
	}
	surface_reset_target()
		
	surface_set_target(render_surface_lens)
	{
		render_shader_obj = shader_map[?shader_add]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_add_set(bloomsurf, render_camera.value[e_value.CAM_BLOOM_INTENSITY], render_camera.value[e_value.CAM_BLOOM_BLEND])
		}
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
}

return resultsurf
