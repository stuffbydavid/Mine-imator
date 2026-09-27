/// render_high_samples_unpack()

function render_high_samples_unpack()
{
	// Unpack render from sample data
	surface_set_target(render_target)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_samples_unpack]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_samples_unpack_set()
		}
		gpu_set_blendmode_ext(bm_one, bm_zero)
		draw_blank(0, 0, render_width, render_height)
		gpu_set_blendmode(bm_normal)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
}