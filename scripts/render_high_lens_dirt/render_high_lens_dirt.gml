/// render_high_lens_dirt(basesurf)
/// @arg basesurf

function render_high_lens_dirt(prevsurf)
{
	// Blur lens surface
	var lenssurftemp, resultsurf;
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	lenssurftemp = render_surface[0]
	
	render_shader_obj = shader_map[?shader_blur]
	with (render_shader_obj)
		shader_set(shader)
	
	// Radius changes based on the render height to make it consistant with the size of the render
	var baseradius = ((render_camera.value[e_value.CAM_LENS_DIRT_RADIUS] * 10) * render_height / 500);
	gpu_set_tex_repeat(false)
	gpu_set_texfilter(true)
	
	for (var i = 0; i < 3; i++)
	{
		var radius = baseradius / (1 + 1.333 * i);
		
		// Horizontal
		surface_set_target(lenssurftemp)
		{
			with (render_shader_obj)
				shader_blur_set(render_width, render_height, radius, 1, 0)
			draw_surface_exists(render_surface_lens, 0, 0)
		}
		surface_reset_target()
		
		// Vertical
		surface_set_target(render_surface_lens)
		{
			with (render_shader_obj)
				shader_blur_set(render_width, render_height, radius, 0, 1)
			draw_surface_exists(lenssurftemp, 0, 0)
		}
		surface_reset_target()
	}
	
	with (render_shader_obj)
		shader_clear()
	
	gpu_set_tex_repeat(true)
	gpu_set_texfilter(false)
	
	// Multiply lens with dirt
	gpu_set_blendmode_ext(bm_zero, bm_src_color)
	surface_set_target(render_surface_lens)
	{
		var texobj = render_camera.value[e_value.TEXTURE_OBJ];
		draw_image_box_cover(texobj.texture, 0, 0, render_width, render_height)
	}
	surface_reset_target()
	gpu_set_blendmode(bm_normal)
	
	// Apply lens dirt
	resultsurf = render_high_get_apply_surf()
	
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_add]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_add_set(render_surface_lens, render_camera.value[e_value.CAM_LENS_DIRT_INTENSITY] * 10, c_white, render_camera.value[e_value.CAM_LENS_DIRT_POWER])
		}
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	return resultsurf
}
