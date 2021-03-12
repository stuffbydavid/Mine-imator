/// action_tl_marker_delete()

var marker;

if (history_undo)
{
	marker = new(obj_marker);
	marker.save_id = history_data.marker_save_id
	marker.name = history_data.marker_name
	marker.color = history_data.marker_color
	marker.pos = history_data.marker_pos
	
	ds_list_add(timeline_marker_list, marker)
}
else
{
	var hobj;
	marker = list_item_value
	
	if (!history_redo)
	{
		hobj = history_set(action_tl_marker_delete)
		
		with (hobj)
		{
			marker_save_id = marker.save_id
			marker_name = marker.name
			marker_color = marker.color
			marker_pos = marker.pos
		}
	}
	else
		hobj = history_data
	
	instance_destroy(save_id_find(hobj.marker_save_id))
	
}

marker_list_sort()
