/// action_tl_marker_new()

if (history_undo)
{
	instance_destroy(save_id_find(history_data.marker_save_id))
}
else
{
	var hobj, marker;
	hobj = null
	
	if (!history_redo)
	{
		hobj = history_set(action_tl_marker_new)
		marker = new(obj_marker)
		
		with (hobj)
		{
			marker_save_id = save_id_get(marker)
			marker_pos = marker.pos
			marker_color = marker.color
			marker_name = marker.name
		}
		
		action_tl_marker_editor(marker)
	}
	else
	{
		marker = new(obj_marker)
		marker.pos = history_data.marker_pos
		marker.color = history_data.marker_color
		marker.name = history_data.marker_name
	}
	
	ds_list_add(timeline_marker_list, marker)
}

marker_list_sort()
