/// history_pop()
/// @desc Clears the history in front of the marker.

function history_pop()
{
	project_changed = true
	action_tl_play_break()
	
	if (history_pos > 0)
	{
		history_amount -= history_pos
		for (var h = 0; h < history_amount; h++)
		{
			if (h < history_pos)
			{
				with (history[h])
				{
					with (obj_history_save)
						if (hobj = other.id)
							instance_destroy()
					instance_destroy()
				}
			}
			history[h] = history[h + history_pos]
		}
	}
	
	history_pos = 0
	
	render_samples = -1
	history_resource_update = true
}
