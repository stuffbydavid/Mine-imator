/// app_stop_place()

function app_stop_place()
{
	if (place_target_tl_part_of != null)
		with (place_target_tl_part_of)
			tl_mark_place_target(false)

	var par;
	par = place_tl.parent
	with (history[0])
	{
		parent = par
		parent_save_id = save_id_get(par)
	}

	with (place_tl)
		tl_mark_placed(false)
	
	place_tl = null
	
	window_busy = ""
	mouse_clear(mb_left)
}
