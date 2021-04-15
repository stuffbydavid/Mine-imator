/// action_tl_color_tag(color)

if (history_undo)
{
	with (history_data)
	{
		for (var t = 0; t < save_var_amount; t++)
		{
			with (save_id_find(save_var_save_id[t]))
				color_tag = other.save_var_old_value[t]
		}
	}
}
else if (history_redo)
{
	with (history_data)
	{
		for (var t = 0; t < save_var_amount; t++)
		{
			with (save_id_find(save_var_save_id[t]))
				color_tag = other.save_var_new_value[t]
		}
	}
}
else
{
	var hobj = history_save_var_start(action_tl_color_tag, false);
	
	// Apply to selected objects
	if (list_item_value.selected)
	{
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, other.color_tag, argument0)
			
			color_tag = argument0
		}
	}
	else // Only apply to right-clicked object
	{
		with (list_item_value)
		{
			with (hobj)
				history_save_var(other.id, other.color_tag, argument0)
			
			color_tag = argument0
		}
	}
}
