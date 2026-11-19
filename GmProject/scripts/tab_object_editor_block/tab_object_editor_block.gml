function tab_object_editor_block()
{
	// Block
	var picker, selected, asset, states, pickerh;
	picker = tab.block_picker
	selected = obj_edit.block_name
	asset = mc_assets.block_name_map[?selected]
	states = obj_edit.block_state
	
	content_capwid = 0
	state_settings_load(asset, false, states, dw, picker.grid_view)
	
	// Picker
	pickerh = max(0, dh - state_settings_height - 8)
	draw_asset_picker(picker, obj_edit.block_tex, selected, states, dx, dy, dw, pickerh)

	dy += pickerh + 8
	
	// State settings
	if (content_mouseon)
		window_scroll_focus = string(picker.scroll)

	dy += draw_state_settings(picker.search_tbx.text, action_lib_block_state, dx, dy, dw, obj_edit.block_tex, tab.state_picker)
}
