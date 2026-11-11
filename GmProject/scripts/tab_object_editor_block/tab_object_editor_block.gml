function tab_object_editor_block()
{
	// Block
	var picker, selected, asset, states, statesh, pickerh;
	picker = tab.block_picker
	selected = obj_edit.block_name
	asset = mc_assets.block_name_map[?selected]
	states = obj_edit.block_state
	
	content_capwid = 0
	statesh = minecraft_asset_get_state_settings_height(asset)
	pickerh = max(0, dh - statesh - 8)
	
	// Picker
	draw_asset_picker(obj_edit.block_tex, picker, selected, states, dx, dy, dw, pickerh)

	dy += pickerh + 8
	
	// State settings
	dy += draw_state_settings(asset, states, picker, action_lib_block_state, dx, dy, dw)

	if (content_mouseon)
		window_scroll_focus = string(picker.scroll)
}
