/// action_tl_keyframes_create()

function action_tl_keyframes_create()
{
	if (history_undo)
	{
		with (history_data)
		{
			for (var t = 0; t < tl_create_amount; t++)
			{
				with (save_id_find(tl_create_save_id[t]))
				{
					with (keyframe_list[|other.tl_create_index[t]])
						instance_destroy()
					
					tl_update_values()
				}
			}
		}
	}
	else if (history_redo)
	{
		with (history_data)
		{
			for (var t = 0; t < tl_create_amount; t++)
			{
				with (save_id_find(tl_create_save_id[t]))
				{
					tl_keyframe_add(other.marker_pos)
					tl_update_values()
				}
			}
		}
	}
	else
	{
		var hobj = history_set(action_tl_keyframes_create);
		with (hobj)
		{
			marker_pos = app.timeline_marker
			tl_create_amount = 0
		}
		
		with (obj_timeline)
		{
			if (!selected || (keyframe_current && keyframe_current.position = app.timeline_marker))
				continue
			
			var kf = tl_keyframe_add(app.timeline_marker);
			hobj.tl_create_save_id[hobj.tl_create_amount] = save_id
			hobj.tl_create_index[hobj.tl_create_amount] = ds_list_find_index(keyframe_list, kf)
			hobj.tl_create_amount++
			
			update_matrix = true
		}
	}
	
	tl_update_matrix()
	tl_update_length()
	
	app_update_tl_edit()
}
