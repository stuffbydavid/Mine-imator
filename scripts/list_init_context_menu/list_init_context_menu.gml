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
		
		// Advanced colors
		if (context_menu_group = e_context_group.COLOR)
		{
			var text = (frame_editor.color.advanced ? "contextmenuadvancedcolorshide" : "contextmenuadvancedcolorsshow");
			list_item_add(text_get(text), null, "", null, icons.ADVANCED_COLORS, null, action_group_advanced_colors, true)
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
	
	// Timeline object list
	case "timelinelist":
	{
		list_item_add(text_get("contextmenutladdfolder"), null, "", null, icons.FOLDER, null, action_tl_folder, true)
		list_item_add(text_get("contextmenutlselectkeyframes"), context_menu_value, "", null, icons.KEYFRAME, null, action_tl_select_keyframes)
		
		list_item_add(text_get("contextmenutlcolortag"), null, "", null, icons.TAG, icons.ARROW_RIGHT_SMALL, null)
		list_item_last.context_menu_name = "color"
		
		list_item_add(text_get("contextmenutlexpandchildren"), null, "", null, icons.EXPAND, null, action_tl_extend_children)
		list_item_add(text_get("contextmenutlcollapsechildren"), null, "", null, icons.COLLAPSE, null, action_tl_collapse_children)
		
		list_item_add(text_get("contextmenutlduplicate"), null, "", null, icons.DUPLICATE, null, action_tl_duplicate, true)
		list_item_last.disabled = (tl_edit = null)
		
		list_item_add(text_get("contextmenutldelete"), null, "", null, icons.DELETE, null, action_tl_remove)
		list_item_last.disabled = (tl_edit = null)
		
		list_item_add(text_get("contextmenutlexport"), null, "", null, icons.EXPORT, null, object_save)
		list_item_last.disabled = !timeline_settings
		
		list_item_add(text_get("contextmenutlselectall"), null, "", null, icons.SELECT_ALL, null, action_tl_select_all, true)
		list_item_add(text_get("contextmenutlexpandall"), null, "", null, icons.EXPAND, null, action_tl_extend_all)	
		list_item_add(text_get("contextmenutlcollapseall"), null, "", null, icons.COLLAPSE, null, action_tl_collapse_all)
		
		break
	}
	
	// Timeline
	case "timeline":
	{
		// Transition
		list_item_add(text_get("contextmenutlkeyframestransition"), null, "", null, icons.TRANSITION, icons.ARROW_RIGHT_SMALL, null, true)
		list_item_last.disabled = !timeline_settings_keyframes
		list_item_last.context_menu_script = menu_transitions
		list_item_last.context_menu_width = 244
		list_item_last.context_menu_height = 438
		
		// Keyframes
		list_item_add(text_get("contextmenutlkeyframescut"), null, "", null, icons.CUT_KEYFRAMES, null, action_tl_keyframes_cut, true)
		list_item_last.disabled = !timeline_settings_keyframes
		
		list_item_add(text_get("contextmenutlkeyframescopy"), null, "", null, icons.COPY_KEYFRAMES, null, tl_keyframes_copy)
		list_item_last.disabled = !timeline_settings_keyframes
		
		list_item_add(text_get("contextmenutlkeyframespaste"), timeline_insert_pos, "", null, icons.PASTE_KEYFRAMES, null, action_tl_keyframes_paste)
		list_item_last.disabled = (copy_kf_amount = 0)
		
		list_item_add(text_get("contextmenutlkeyframesdelete"), null, "", null, icons.DELETE_KEYFRAMES, null, action_tl_keyframes_remove)
		list_item_last.disabled = !timeline_settings_keyframes
		
		list_item_add(text_get("contextmenutlkeyframesexport"), null, "", null, icons.EXPORT_KEYFRAMES, null, keyframes_save)
		list_item_last.disabled = !timeline_settings_keyframes_export
		
		// Walk/run cycles
		list_item_add(text_get("contextmenutlkeyframeswalk"), timeline_settings_walk_fn, "", null, icons.WALK, null, action_tl_load_loop, true)
		list_item_last.disabled = !file_exists_lib(timeline_settings_walk_fn)
		
		list_item_add(text_get("contextmenutlkeyframesrun"), timeline_settings_run_fn, "", null, icons.RUN, null, action_tl_load_loop)
		list_item_last.disabled = !file_exists_lib(timeline_settings_run_fn)
		
		// Add marker
		list_item_add(text_get("contextmenutlmarkeradd"), null, "", null, icons.MARKER_ADD, null, action_tl_marker_new, true)
		
		// Check if position is available
		if (timeline_show_markers)
		{
			for (var i = 0; i < ds_list_size(timeline_marker_list); i++)
			{
				if (timeline_marker_list[|i].pos = round(app.timeline_marker))
				{
					list_item_last.disabled = true
					break
				}
			}
		}
		else
			list_item_last.disabled = true
		
		break
	}
	
	// Marker
	case "timelinemarker":
	{
		list_item_add(text_get("contextmenutlmarkeredit"), context_menu_value, "", null, icons.EDIT, null, action_tl_marker_editor, true)
		list_item_add(text_get("contextmenutlmarkerdelete"), null, "", null, icons.DELETE, null, action_tl_marker_delete)
		
		break
	}
	
	// Accent color picker
	case "color":
	{
		list_item_add(text_get("contextmenucolornone"), null, "", null, icons.CLOSE, null, action_tl_color_tag_remove, true)
		
		for (var i = 0; i <= 8; i++)
		{
			list_item_add(text_get("contextmenucolor" + string(i)), i, "", spr_16, null, null, action_tl_color_tag)
			list_item_last.thumbnail_blend = setting_theme.accent_list[i]
		}
		
		break
	}
}

return list_init_end()