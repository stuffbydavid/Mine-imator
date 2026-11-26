/// @desc Renders ground without material or lighting setup in fast passes.

function render_world_ground_fast()
{
	var res = res_eval(env_ground_tex);
	render_apply_res(res)
	
	if (render_mode != e_render_mode.CLICK)
		render_set_uniform_color(e_uniform.BLEND_COLOR, c_white, 1)
	
	shader_texture_filter_mipmap = !render_depth_pass && app.project_render_texture_filtering
	
	if (env_ground_ani)
		render_set_texture(res, env_ground_ani_texture[block_texture_get_frame()])
	else
		render_set_texture(res, env_ground_texture)
	
	// Submit ground mesh at an offset from the camera
	var sheet, groundscale, groundsquare, xo, yo;
	sheet = minecraft_assets_block_texture_picker_slot_decode(env_ground_slot)[0]
	groundscale = (sheet >= 0 && sheet < e_block_sheet.static_amount ? block_size_list[sheet] / block_size : 1)
	groundsquare = block_size * groundscale
	xo = (cam_from[X] div groundsquare) * groundsquare
	yo = (cam_from[Y] div groundsquare) * groundsquare
	
	vbuffer_render(env_ground_vbuffer, point3D(xo, yo, 0), point3D(0, 0, 90), point3D(block_size / 16 * groundscale, block_size / 16 * groundscale, 1))
	
	shader_texture_filter_mipmap = false
	
	return 0
}
