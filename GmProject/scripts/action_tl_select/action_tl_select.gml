/// action_tl_select(timeline)
/// @arg timeline

function action_tl_select(tl)
{
	if (history_undo)
	{
		with (history_data)
		{
			history_restore_tl_select()
			for (var t = 0; t < extend_amount; t++)
				with (save_id_find(extend_save_id[t]))
					tree_extend = other.extend_value[t]
		}
	}
	else
	{
		var shift, par, hobj;
		hobj = null
		
		if (history_redo)
		{
			tl = save_id_find(history_data.tl_save_id)
			shift = history_data.shift
		}
		else
		{
			shift = keyboard_check(vk_shift)
			hobj = history_set(action_tl_select)
			with (hobj)
			{
				id.tl_save_id = save_id_get(tl)
				id.shift = shift
				history_save_tl_select()
				extend_amount = 0
			}
		}
		
		// Extend parents
		par = tl.parent
		while (par != app)
		{
			with (hobj)
			{
				extend_save_id[extend_amount] = par.save_id
				extend_value[extend_amount] = par.tree_extend
				extend_amount++
			}
			par.tree_extend = true
			par = par.parent
		}
		
		// Select
		if (!shift)
		{
			tl_deselect_all()
		}
		with (tl)
		{
			tl_update_recursive_select()
			tl_select()
		}
	}
	
	app_update_tl_edit()
	tl_update_list()
}
