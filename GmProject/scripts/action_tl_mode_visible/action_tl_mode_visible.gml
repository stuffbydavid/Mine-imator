/// @arg enabled
/// @arg [timeline]
/// @arg [historyobject]

function action_tl_mode_visible(enabled, tl = null, hobj = null)
{
	var renderer = renderer_edit;
	
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					mode_visible[other.mode_renderer] = other.save_var_old_value[t]
	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					mode_visible[other.mode_renderer] = other.save_var_new_value[t]
	}
	else if (tl = null)
	{
		hobj = history_save_var_start(action_tl_mode_visible, false)
		hobj.mode_renderer = renderer
		
		with (obj_timeline)
			if (selected)
				action_tl_mode_visible(enabled, id, hobj)
	}
	else
	{
		renderer = hobj.mode_renderer
		with (hobj)
			history_save_var(tl, tl.mode_visible[renderer], enabled)
		
		tl.mode_visible[renderer] = enabled
		
		for (var i = 0; i < ds_list_size(tl.tree_list); i++)
			if (!tl.tree_list[|i].selected)
				action_tl_mode_visible(enabled, tl.tree_list[|i], hobj)
	}
}
