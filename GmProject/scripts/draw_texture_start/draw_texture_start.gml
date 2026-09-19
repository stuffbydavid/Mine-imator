/// draw_texture_start()

function draw_texture_start()
{
	render_shader_obj = shader_map[?shader_draw_texture]
	with (render_shader_obj)
		shader_use()

	if (shader_clip_active && !is_cpp())
	{
		render_set_uniform_int("uClipEnabled", 1)
		render_set_uniform("uClipBox", [shader_clip_x, shader_clip_y, shader_clip_width, shader_clip_height])
		render_set_uniform("uScreenSize", [1, 1])
	}
	else
		render_set_uniform_int("uClipEnabled", 0)
}
