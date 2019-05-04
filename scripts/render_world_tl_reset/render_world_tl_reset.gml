/// render_world_tl_reset()
/// @desc Resets render values after finishing rendering timelines

matrix_world_reset()
render_set_culling(true)
shader_texture_surface = false
shader_texture_filter_linear = false
shader_texture_filter_mipmap = false

if (gpu_get_tex_filter())
	gpu_set_tex_filter(false)
