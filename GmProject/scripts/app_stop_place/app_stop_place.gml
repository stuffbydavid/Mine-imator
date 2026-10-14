function app_stop_place(keep = false, clearmouse = true)
{
	if (build_first_person)
		action_build_first_person(false)

	if (place_build)
	{
		action_build_structure(null, false)
			
		place_build = false
		place_busy = "place"
		place_tl = null
		place_history = null
		place_target_tl = null
		place_target_tl_root = null
		place_content_mouseon = null
		
		window_busy = ""
		window_place = false
		view_changed()
		
		tab_close(build_tool)
		if (obj_edit = build_settings)
			obj_edit = null
		
		if (clearmouse)
			mouse_clear(mb_left)
		
		return 0
	}

	if (place_target_tl_root != null)
		with (place_target_tl_root)
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
	window_place = false
	view_changed()
	
	if (clearmouse)
		mouse_clear(mb_left)
}
