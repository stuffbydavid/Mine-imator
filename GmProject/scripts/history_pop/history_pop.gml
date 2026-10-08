/// @desc Clears the history in front of the marker.

function history_pop()
{
	action_tl_play_break()
	
	if (history_pos > 0)
	{
		for (var h = 0; h < history_pos; h++)
		{
			with (history[h])
			{
				with (obj_history_save)
					if (hobj = other.id)
						instance_destroy()
				
				instance_destroy()
			}
		}

		for (var h = history_pos; h < history_amount; h++)
			history[h - history_pos] = history[h]
		
		history_amount -= history_pos
	}
	
	history_pos = 0
	
	render_samples = -1
	render_scene_bounds = null
	view_changed()
	
	history_resource_update = true
	project_changed = true
}
