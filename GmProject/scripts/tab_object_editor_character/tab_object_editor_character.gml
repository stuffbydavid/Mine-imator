function tab_object_editor_character()
{
	var picker;
	content_capwid = 0
			
	switch (obj_edit.type)
	{
		case e_temp_type.CHARACTER:
		{
			picker = tab.char_picker
			break
		}
		case e_temp_type.EQUIPMENT:
		{
			picker = tab.equipment_picker
			break
		}
		
		case e_temp_type.SPECIAL_BLOCK:
		{
			picker = tab.special_block_picker
			break
		}
		
		case e_temp_type.MODEL_PART:
		{
			picker = tab.model_part_model_picker
			content_capwid = text_caption_width("template_editor/model_part")
			break
		}
	}
			
	// Reserve space for the selected model's state controls
	var script, statesh, pickerh, selected, asset, states, partname;
	selected = obj_edit.model_name
	asset = mc_assets.model_name_map[?selected]
	states = obj_edit.model_state
	partname = obj_edit.model_part_name

	if (obj_edit.type = e_temp_type.MODEL_PART)
		script = action_lib_model_part_model_state
	else
		script = action_lib_model_state
	
	state_settings_load(asset, false, states, dw, picker.grid_view)
	statesh = state_settings_height
	if (obj_edit.type = e_temp_type.MODEL_PART)
		statesh += 32
	
	pickerh = max(0, dh - statesh - 8)
	
	// Model picker
	draw_asset_picker(picker, obj_edit.model_tex, selected, states, dx, dy, dw, pickerh)

	dy += pickerh + 8
	
	// Model part
	if (obj_edit.type = e_temp_type.MODEL_PART)
	{
		draw_button_menu("template_editor/model_part", e_menu.LIST, dx, dy, dw, 24, partname, minecraft_asset_get_name("model/part", partname), action_lib_model_part_name, false, null, null, "", c_white, 1, content_capwid)
		dy += 32
	}

	// State settings
	if (content_mouseon)
		window_scroll_focus = string(picker.scroll)

	dy += draw_state_settings(picker.search_tbx.text, script, dx, dy, dw, obj_edit.model_tex, tab.state_picker)
}
