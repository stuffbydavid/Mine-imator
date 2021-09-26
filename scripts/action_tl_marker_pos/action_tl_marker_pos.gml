/// action_tl_marker_pos()

function action_tl_marker_pos()
{
	var marker;
	
	if (history_undo)
	{
		marker = save_id_find(history_data.marker_save_id)
		marker.pos = history_data.marker_pos_prev
	}
	else
	{
		var hobj;
		
		if (!history_redo)
		{
			marker = timeline_marker_edit
			hobj = history_set(action_tl_marker_pos)
			
			with (hobj)
			{
				marker_save_id = save_id_get(marker)
				marker_pos_prev = marker.edit_pos
				marker_pos_new = marker.pos
			}
			
			marker.pos = hobj.marker_pos_new
		}
		else
		{
			with (save_id_find(history_data.marker_save_id))
				pos = history_data.marker_pos_new
		}
	}
	
	marker_list_sort()
}
