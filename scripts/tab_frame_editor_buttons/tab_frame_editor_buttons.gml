/// tab_frame_editor_buttons()

function tab_frame_editor_buttons()
{
	var name, bx, by, alpha;
	bx = dx + dw - 24
	by = dy
	
	if (context_menu_name = "")
		context_menu_group = context_menu_group_temp
	
	name = "buttons" + string(context_menu_group_temp)
	alpha = microani_arr[e_microani.HOVER]
	
	draw_set_alpha(alpha)
	
	if (context_menu_group_temp = e_context_group.SCALE)
	{
		if (frame_editor.transform.scale_all)
			draw_set_alpha(1)
		
		draw_button_icon(name + "link", bx, by, 24, 24, frame_editor.transform.scale_all, icons.LINK, action_group_combine_scale, false, "contextmenuscalecombine")
		bx -= 28
		
		draw_set_alpha(alpha)
	}
	
	draw_button_icon(name + "reset", bx, by, 24, 24, false, icons.RESET, action_group_reset, false, "contextmenugroupreset")
	bx -= 28
	
	draw_button_icon(name + "paste", bx, by, 24, 24, false, icons.PASTE, action_group_paste, false, "contextmenugrouppaste")
	bx -= 28
	
	draw_button_icon(name + "copy", bx, by, 24, 24, false, icons.COPY, action_group_copy, false, "contextmenugroupcopy")
	bx -= 28
	
	draw_set_alpha(1)
}
