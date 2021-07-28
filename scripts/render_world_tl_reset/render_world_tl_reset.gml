/// render_world_tl_reset()
/// @desc Resets render values after finishing rendering timelines

function render_world_tl_reset()
{
	matrix_world_reset()
	render_set_culling(true)
	shader_texture_filter_linear = false
	shader_texture_filter_mipmap = false
	
	render_texture_prev = null
	render_blend_prev = null
	render_alpha_prev = null
}
