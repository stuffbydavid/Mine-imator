/// @desc Renders a box wireframe while using the build tool.

function render_world_build_box()
{
	var movingview, prevshader;
	movingview = (window_busy = "view/rotate_camera" || window_busy = "view/move_camera" || window_busy = "view/pan_camera")
	if (window_state != "" || build_box_render = null || !content_mouseon || movingview)
		return 0
	
	prevshader = render_shader_obj
	render_shader_obj = shader_map[?shader_build_box]
	with (render_shader_obj)
		shader_use()
		
	render_set_uniform_vec2(e_uniform.VIEWPORT_SIZE, render_width, render_height)
	render_set_uniform(e_uniform.LINE_LENGTH, block_half_size * 1.0025 * 2)
	
	gpu_set_zwriteenable(false)
	
	render_set_culling(false)
	vbuffer_render_matrix(build_box_render, build_box_matrix)
	render_set_culling(true)
	
	gpu_set_zwriteenable(true)
	
	with (render_shader_obj)
		shader_clear()
	
	render_shader_obj = prevshader
}
