/// recent_update_sort(list)
/// @arg list
/// @desc Sorts a list of models based on the sort mode

function recent_update_sort(list)
{
	var listsize, ascend, datesort, datalist, prevlist, newlist;
	listsize = ds_list_size(list)
	ascend = (recent_sort_mode = e_recent_sort.date_newest || recent_sort_mode = e_recent_sort.name_az)
	datesort = (recent_sort_mode = e_recent_sort.date_newest || recent_sort_mode = e_recent_sort.date_oldest)
	datalist = ds_list_create()
	prevlist = ds_list_create()
	newlist = ds_list_create()
	
	if (datesort)
	{
		for (var i = 0; i < listsize; i++)
			ds_list_add(datalist, list[|i].last_opened)
		
		ds_list_sort(datalist, !ascend)
		ds_list_copy(prevlist, list)
		
		// Look for sorted values and fill list
		for (var i = 0; i < listsize; i++)
		{
			for (var j = 0; j < ds_list_size(prevlist); j++)
			{
				if (datalist[|i] = prevlist[|j].last_opened)
				{
					ds_list_add(newlist, prevlist[|j])
					ds_list_delete(prevlist, j)
					break
				}
			}
		}
	}
	else
	{	
		for (var i = 0; i < listsize; i++)
			ds_list_add(datalist, list[|i].name)
		
		ds_list_sort(datalist, ascend)
		ds_list_copy(prevlist, list)
	
		// Look for sorted values and fill list
		for (var i = 0; i < listsize; i++)
		{
			for (var j = 0; j < ds_list_size(prevlist); j++)
			{
				if (datalist[|i] = prevlist[|j].name)
				{
					ds_list_add(newlist, prevlist[|j])
					ds_list_delete(prevlist, j)
					break
				}
			}
		}
	}
	
	ds_list_copy(list, newlist)
	ds_list_destroy(datalist)
	ds_list_destroy(prevlist)
	ds_list_destroy(newlist)
}
