/// CppSeparate void clip_end()
/// clip_end()

function clip_end()
{
	shader_clip_active = false
	
	with (render_shader_obj)
		shader_clear()
}
