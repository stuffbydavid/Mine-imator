/// app_stop_place([keep, clearmouse])

function app_stop_place(keep = false, clearmouse = true)
{
	var remove, historyindex;
	remove = place_build && !keep
	historyindex = -1
	
	if (place_build)
	{
		for (var h = 0; h < history_amount; h++)
		{
			if (history[h] = place_history)
			{
				historyindex = h
				break
			}
		}
	}

	if (place_build && keep)
	{
		with (place_tl)
		{
			tl_create_temp_copy(app.bench_settings)
			tl_create_temp_copy(app.place_history.bench_save_obj)
		}
		
		with (place_history.bench_save_obj)
			temp_get_save_ids()

		if (historyindex > 0)
		{
			history_pos = historyindex
			history_pop()
		}
	}

	if (place_target_tl_part_of != null)
		with (place_target_tl_part_of)
			tl_mark_place_target(false)

	var par = place_tl.parent;
	with (place_history)
	{
		parent = par
		parent_save_id = save_id_get(par)
	}

	with (place_tl)
		tl_mark_placed(false)

	if (remove)
	{
		with (place_tl)
		{
			tl_remove_clean()
			instance_destroy()
		}

		with (obj_timeline)
			if (delete_ready)
				instance_destroy()

		if (historyindex >= 0)
		{
			history_pos = historyindex + 1
			history_pop()
		}
	}
	tl_update_list()

	place_tl = null
	place_tl_render_step = 0
	place_target_tl_model_part = false
	place_history = null
	
	if (place_build && place_view_second_show)
		view_second.show = true
	place_build = false
	
	place_view_second_show = false
	place_content_mouseon = null
	
	window_busy = ""
	
	if (clearmouse)
		mouse_clear(mb_left)
}
