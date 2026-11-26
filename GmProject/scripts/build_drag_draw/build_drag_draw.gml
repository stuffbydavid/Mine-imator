/// @desc Draws the dragged build block and handles dropping it.

function build_drag_draw()
{
	if (window_state != "" || window_get_current() != e_window.MAIN || !place_build || !build_drag_active)
		return 0

	if (!mouse_left)
	{
		build_drag_stop()
		return 0
	}

	var block, asset, res, tex;
	block = build_drag_block
	asset = block[0] ? mc_assets.model_name_map[?block[1]] : mc_assets.block_name_map[?block[1]]
	res = res_eval(build_drag_res)
	with (res)
		tex = res_get_asset_picker_texture(asset, block[2])

	mouse_cursor = cr_drag
	window_set_cursor(cr_drag)

	draw_set_alpha(1)
	shader_texture_filter_linear = false
	
	if (tex != null)
	{
		draw_texture_start()
		draw_texture_part(tex, mouse_x - 32, mouse_y - 32, 0, 0, 64, 64)
		draw_texture_done()
	}
}
