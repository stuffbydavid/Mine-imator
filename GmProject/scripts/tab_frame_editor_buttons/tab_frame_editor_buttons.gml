function tab_frame_editor_buttons()
{
	var bx, by, alpha;
	bx = dx + dw - 24
	by = dy
	
	if (context_menu_name = "")
		context_menu_group = context_menu_group_temp
	
	content_name = "buttons" + string(context_menu_group_temp)
	alpha = microani_arr[e_microani.HOVER]
	
	draw_set_alpha(alpha)
	
	if (context_menu_group_temp = e_context_group.SCALE)
	{
		if (frame_editor.transform.scale_all)
			draw_set_alpha(1)
		
		draw_button_icon(content_name + "link", bx, by, 24, 24, frame_editor.transform.scale_all, icons.LINK, action_group_combine_scale, false, frame_editor.transform.scale_all ? "context_menu/scale_separate" : "context_menu/scale_combine")
		bx -= 28
		
		draw_set_alpha(alpha)
	}
	
	if (context_menu_group_temp = e_context_group.BEND && setting_advanced_mode)
	{
		if (frame_editor.transform.bend_sliders)
			draw_set_alpha(1)
		
		draw_button_icon(content_name + "sliders", bx, by, 24, 24, frame_editor.transform.bend_sliders, icons.SLIDERS, action_group_bend_sliders, false, frame_editor.transform.bend_sliders ? "context_menu/bend_wheels" : "context_menu/bend_sliders")
		bx -= 28
		
		draw_set_alpha(alpha)
	}
	
	draw_button_icon(content_name + "reset", bx, by, 24, 24, false, icons.RESET, action_group_reset, false, "context_menu/group/reset")
	bx -= 28
	
	draw_button_icon(content_name + "paste", bx, by, 24, 24, false, icons.PASTE, action_group_paste, context_group_copy_list[|context_menu_group] = null, "context_menu/group/paste")
	bx -= 28
	
	draw_button_icon(content_name + "copy", bx, by, 24, 24, false, icons.COPY, action_group_copy, false, "context_menu/group/copy")
	bx -= 28
	
	draw_set_alpha(1)
}
