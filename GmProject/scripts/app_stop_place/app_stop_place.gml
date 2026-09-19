/// app_stop_place()

function app_stop_place()
{
	var par = place_tl.parent;
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