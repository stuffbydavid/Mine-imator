/// @desc Renders a box wireframe while using the build tool.
/// @arg [scenedepth]

function render_world_build_box(scenedepth = false)
{
	var movingview, prevshader;
	movingview = (window_busy = "view/rotate_camera" || window_busy = "view/move_camera" || window_busy = "view/pan_camera")
	if (window_state != "" || build_box_render = null || !content_mouseon || movingview)
		return 0
	
	prevshader = render_shader_obj
	render_shader_obj = shader_map[?shader_build_box]
	with (render_shader_obj)
		shader_use()

	render_set_uniform_int(e_uniform.DEPTH_TEST, scenedepth)
	render_set_uniform(e_uniform.NEAR, depth_near)
	render_set_uniform(e_uniform.FAR, depth_far)
	render_set_uniform_vec2(e_uniform.VIEWPORT_SIZE, render_width, render_height)
	render_set_uniform(e_uniform.LINE_LENGTH, block_half_size * 1.0025 * 2)

	if (scenedepth)
	{
		var sampler = render_shader_obj.sampler_handle[e_sampler.DEPTH_BUFFER];
		texture_set_stage(sampler, surface_get_texture(render_surface_depth))
		gpu_set_texfilter_ext(sampler, false)
		gpu_set_texrepeat_ext(sampler, false)
	}
	
	gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha)
	gpu_set_ztestenable(!scenedepth)
	gpu_set_zwriteenable(false)
	
	render_set_culling(false)
	vbuffer_render_matrix(build_box_render, build_box_matrix)
	render_set_culling(true)
	
	gpu_set_zwriteenable(true)
	gpu_set_ztestenable(true)
	gpu_set_blendmode(bm_normal)
	
	with (render_shader_obj)
		shader_clear()
	
	render_shader_obj = prevshader
}
