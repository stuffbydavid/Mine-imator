/// app_stop_place(keep, continuebuild, [clearmouse])

function app_stop_place(keep = false, continuebuild = false, clearmouse = true)
{
	if (place_build)
	{
		if (place_target_tl_part_of != null)
			with (place_target_tl_part_of)
				tl_mark_place_target(false)
			
		if (place_view_second_show)
			view_second.show = true
			
		place_build = false
		place_busy = "place"
		place_tl = null
		place_history = null
		place_target_tl = null
		place_target_tl_part_of = null
		place_view_second_show = false
		place_content_mouseon = null
		
		window_busy = ""
		tab_close(build_mode)
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

	// Clear placement state and restore the hidden secondary view
	place_tl = null
	place_history = null
	
	place_view_second_show = false
	place_content_mouseon = null
	
	window_busy = ""
	
	if (clearmouse)
		mouse_clear(mb_left)
}
