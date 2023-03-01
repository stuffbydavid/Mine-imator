/// CppSeparate void clip_begin(IntType, IntType, IntType, IntType)
/// clip_begin(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function clip_begin(xx = 0, yy = 0, w = 0, h = 0)
{
	if (w > 0 && h > 0)
	{
		shader_clip_x = xx
		shader_clip_y = yy
		shader_clip_width = w
		shader_clip_height = h
	}
	
	shader_clip_active = true
	
	render_shader_obj = shader_map[?shader_clip]
	with (render_shader_obj)
	{
		shader_set(shader_clip)
		shader_clip_set(shader_clip_x, shader_clip_y, shader_clip_width, shader_clip_height)
	}
}
