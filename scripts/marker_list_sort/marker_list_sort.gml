/// marker_list_sort()

function marker_list_sort()
{
	var newlist = ds_list_create();
	
	for (var i = 0; i < ds_list_size(timeline_marker_list); i++)
		ds_list_add(newlist, timeline_marker_list[|i].pos)
	
	ds_list_sort(newlist, true)
	
	// Replace indexes with IDs
	for (var i = 0; i < ds_list_size(newlist); i++)
	{
		for (var j = 0; j < ds_list_size(timeline_marker_list); j++)
		{
			if (newlist[|i] = timeline_marker_list[|j].pos)
			{
				newlist[|i] = timeline_marker_list[|j]
				ds_list_delete(timeline_marker_list, j)
				break
			}
		}
	}
	
	// Copy IDs back into marker list
	ds_list_copy(timeline_marker_list, newlist)
	ds_list_destroy(newlist)
}
