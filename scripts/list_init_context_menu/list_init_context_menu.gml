/// list_init_context_menu(name)
/// @arg name

var name = argument0;

list_init_start()

switch (name)
{
	// Component values
	case "contextmenuvalue":
	case "contextmenucategory":
	{	
		// Rotation loops
		if (context_menu_group = e_context_group.ROTATION)
		{
			var text = (frame_editor.rotation.loops ? "contextmenugroupdisableloops" : "contextmenugroupenableloops");
			list_item_add(text_get(text), null, "", null, icons.LOOPS, null, action_group_rotation_loops, true)
		}
		
		// Combine scale
		if (context_menu_group = e_context_group.SCALE)
		{
			var text = (frame_editor.scale.scale_all ? "contextmenuscaleseperate" : "contextmenuscalecombine");
			list_item_add(text_get(text), null, "", null, icons.TOOLSET_SCALE, null, action_group_combine_scale, true)
		}
		
		// Single value copy-paste
		if (name = "contextmenuvalue")
		{
			list_item_add(text_get("contextmenuvaluecut"), null, "", null, icons.CUT, null, action_value_cut, true)
			list_item_add(text_get("contextmenuvaluecopy"), null, "", null, icons.COPY, null, action_value_copy, false)
			
			var caption = "";
			
			if (context_menu_copy_type = e_context_type.NUMBER)
				caption = string(context_menu_copy)
			else if (context_menu_copy_type = e_context_type.COLOR)
				caption = color_to_hex(context_menu_copy)
			else if (context_menu_copy_type = e_context_type.STRING)
				caption = context_menu_copy
			
			list_item_add(text_get("contextmenuvaluepaste"), null, caption, null, icons.PASTE, null, action_value_paste, false)
			list_item_last.disabled = (context_menu_value_type = e_context_type.NONE || (context_menu_copy_type != context_menu_value_type))
			
			list_item_add(text_get("contextmenuvaluereset"), null, "", null, icons.RESET, null, action_value_reset, false)
		}
		
		if (context_menu_group != null && context_group_copy_list[|context_menu_group] != null)
		{
			list_item_add(text_get("contextmenugroupcopy"), null, "", null, icons.COPY_ALL, null, action_group_copy, true)
			list_item_add(text_get("contextmenugrouppaste"), null, "", null, icons.PASTE_ALL, null, action_group_paste, false)
			list_item_add(text_get("contextmenugroupreset"), null, "", null, icons.RESET_ALL, null, action_group_reset, false)
			
			if (context_menu_group = e_context_group.POSITION)
				list_item_add(text_get("contextmenugroupcopyglobalposition"), null, "", null, icons.COPY_ALL, null, action_group_copy_global, true)
		}
		
		
		break
	}
	
	// Textboxes
	case "contextmenutextbox":
	{
		var ctrl = text_get("keycontrol") + " + ";
		list_item_add(text_get("contextmenutextboxcut"), null, ctrl + "X", null, icons.CUT, null, action_textbox_cut, true)
		list_item_last.disabled = (textbox_select_startpos = textbox_select_endpos)
		
		list_item_add(text_get("contextmenutextboxcopy"), null, ctrl + "C", null, icons.COPY, null, action_textbox_copy, false)
		list_item_last.disabled = (textbox_select_startpos = textbox_select_endpos)
		
		list_item_add(text_get("contextmenutextboxpaste"), null, ctrl + "V", null, icons.PASTE, null, action_textbox_paste, false)
		list_item_last.disabled = (clipboard_get_text() = "" || !clipboard_has_text())
		
		list_item_add(text_get("contextmenutextboxselectall"), null, ctrl + "A", null, icons.SELECT_ALL, null, action_textbox_select_all, false)
		break
	}
}

return list_init_end()