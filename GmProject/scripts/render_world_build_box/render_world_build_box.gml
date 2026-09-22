/// render_world_build_box()

function render_world_build_box()
{
	var movingview = window_busy = "viewrotatecamera" || window_busy = "viewmovecamera" || window_busy = "viewpancamera"
	if (window_state != "" || build_box_render = null || !content_mouseon || movingview ||
		(render_mode != e_render_mode.COLOR &&
		 render_mode != e_render_mode.COLOR_FOG &&
		 render_mode != e_render_mode.COLOR_FOG_LIGHTS))
		return 0
	
	var prevshader = render_shader_obj;
	render_shader_obj = shader_map[?shader_build_box]
	with (render_shader_obj)
		shader_use()
		
	render_set_uniform_vec2("uViewportSize", render_width, render_height)
	render_set_uniform("uLineLength", block_half_size * 1.0025 * 2)
	
	gpu_set_zwriteenable(false)
	render_set_culling(false)
	vbuffer_render_matrix(build_box_render, build_box_matrix)
	render_set_culling(true)
	gpu_set_zwriteenable(true)
	
	with (render_shader_obj)
		shader_clear()
	
	render_shader_obj = prevshader
	with (render_shader_obj)
		shader_use()
}
