function action_tl_marker_delete()
{
	if (history_undo)
	{
		var marker = new_obj(obj_marker);
		with (marker)
		{
			save_id = history_data.marker_save_id
			name = history_data.marker_name
			color = history_data.marker_color
			pos = history_data.marker_pos
		}
		
		ds_list_add(timeline_marker_list, marker)
	}
	else
	{
		var marker, hobj;
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
}
