function tab_frame_editor_sound()
{
	if (tl_edit.value[e_value.SOUND_OBJ] != null)
		content_text = tl_edit.value[e_value.SOUND_OBJ].display_name
	else
		content_text = text_get("list/none")
	
	tab_control_menu()
	draw_button_menu("frame_editor/sound/file", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.SOUND_OBJ], content_text, action_tl_frame_sound_obj)
	tab_next()
	
	tab_control_meter()
	draw_meter("frame_editor/sound/volume", dx, dy, dw, round(tl_edit.value[e_value.SOUND_VOLUME] * 100), 0, 100, 100, 1, tab.sound.tbx_volume, action_tl_frame_sound_volume)
	tab_next()
	
	tab_control_meter()
	draw_meter("frame_editor/sound/pitch", dx, dy, dw, round(tl_edit.value[e_value.SOUND_PITCH] * 100), 50, 200, 100, 1, tab.sound.tbx_pitch, action_tl_frame_sound_pitch)
	tab_next()
	
	// Sound start/end
	textfield_group_add("frame_editor/sound/start", tl_edit.value[e_value.SOUND_START], tl_edit.value_default[e_value.SOUND_START], action_tl_frame_sound_start, axis_edit, tab.sound.tbx_start, null, max(0.01, 0.005 * abs(tl_edit.value[e_value.SOUND_START])), 0, no_limit)
		
	textfield_group_add("frame_editor/sound/end", tl_edit.value[e_value.SOUND_END], tl_edit.value_default[e_value.SOUND_END], action_tl_frame_sound_end, axis_edit, tab.sound.tbx_end, null, max(0.01, 0.005 * abs(tl_edit.value[e_value.SOUND_END])), -no_limit, no_limit)
		
	tab_control_textfield(true)
	draw_textfield_group("frame_editor/sound/time", dx, dy, dw, max(0.01, 0.005 * abs(tl_edit.value[e_value.SOUND_END])), -no_limit, no_limit, 0, true)
	tab_next()
}
