/// action_tl_select_keyframes(timeline)
/// @arg timeline

function action_tl_select_keyframes(tl)
{
	if (history_undo)
	{
		with (history_data)
			history_restore_tl_select()
	}
	else
	{
		var shift;
		
		if (history_redo)
		{
			shift = history_data.shift
			
			if (!shift)
				tl_deselect_all()
			
			for (var t = 0; t < history_data.tl_amount; t++)
			{
				tl = save_id_find(history_data.tl_save_id[t])
				
				with (tl)
					tl_select()
				
				for (var k = 0; k < ds_list_size(tl.keyframe_list); k++)
					tl_keyframe_select(tl.keyframe_list[|k])
			}
		}
		else
		{
			var hobj = history_set(action_tl_select_keyframes);
			
			shift = keyboard_check(vk_shift)
			with (hobj)
			{
				tl_amount = 0
				id.shift = shift
				history_save_tl_select()
			}
			
			// Apply to selected objects
			if (tl.selected)
			{
				with (obj_timeline)
				{
					if (!selected)
					{
						if (!shift)
							tl_deselect()
						
						continue
					}
					
					with (hobj)
					{
						tl_save_id[tl_amount] = save_id_get(other)
						tl_amount++
					}
					
					for (var k = 0; k < ds_list_size(keyframe_list); k++)
						tl_keyframe_select(keyframe_list[|k])
				}
			}
			else // Only apply to right-clicked object
			{
				if (!shift)
					tl_deselect_all()
				
				hobj.tl_save_id[0] = save_id_get(tl)
				hobj.tl_amount++
				
				for (var k = 0; k < ds_list_size(tl.keyframe_list); k++)
					tl_keyframe_select(tl.keyframe_list[|k])
			}
		}
	}
	
	app_update_tl_edit()
}
