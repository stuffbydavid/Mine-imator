/// tab_frame_editor_path()

function tab_frame_editor_path()
{
	if (!tl_edit.value_type[e_value_type.TRANSFORM_POS] || tl_edit.type = e_tl_type.PATH || tl_edit.type = e_tl_type.PATH_POINT)
		return 0
	
	// Follow path
	tab_control_switch()
	draw_button_collapse("follow_path", collapse_map[?"follow_path"], null, true, "frameeditorfollowpath")
	tab_next()
	
	if (collapse_map[?"follow_path"])
	{
		var text;
		
		tab_collapse_start()
		
		if (tl_edit.value[e_value.PATH_OBJ] != null)
			text = tl_edit.value[e_value.PATH_OBJ].display_name
		else
			text = text_get("listnone")
		
		tab_control_menu()
		draw_button_menu("frameeditorpath", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.PATH_OBJ], text, action_tl_frame_path)
		tab_next()
		
		// Force
		if (tl_edit.value[e_value.PATH_OBJ])
		{
			context_menu_value_name = "pathoffset"
			
			tab_control_dragger()
			draw_dragger("frameeditorpathoffset", dx, dy, dragger_width, tl_edit.value[e_value.PATH_OFFSET], .1, -no_limit, no_limit, 0, 0.01, tab.constraints.tbx_path_offset, action_tl_frame_path_offset)
			tab_next()
			
			context_menu_value_name = ""
		}
		
		tab_collapse_end()
	}
}
