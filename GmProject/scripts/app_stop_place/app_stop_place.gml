/// app_stop_place(keep, [clearmouse])

function app_stop_place(keep = false, clearmouse = true)
{
	if (place_build)
	{
		action_build_structure(null, false)
			
		place_build = false
		place_busy = "place"
		place_tl = null
		place_history = null
		place_target_tl = null
		place_target_tl_part_of = null
		place_content_mouseon = null
		
		window_busy = ""
		tab_close(build_tool)
		if (obj_edit = build_settings)
			obj_edit = null
		
		if (clearmouse)
			mouse_clear(mb_left)
		
		return 0
	}

	if (place_target_tl_part_of != null)
		with (place_target_tl_part_of)
			tl_mark_place_target(false)

	// Save the final parent so redo restores the placed object correctly
	var par = place_tl.parent;
	with (place_history)
	{
		parent = par
		parent_save_id = save_id_get(par)
	}

	with (place_tl)
		tl_mark_placed(false)

	tl_update_list()
	if (keep)
		tl_focus = place_tl

	// Clear placement state
	place_tl = null
	place_history = null
	
	place_content_mouseon = null
	
	window_busy = ""
	
	if (clearmouse)
		mouse_clear(mb_left)
}
