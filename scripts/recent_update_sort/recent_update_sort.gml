/// recent_update_sort(list)
/// @arg list
/// @desc Sorts a list of models based on the sort mode

var list = argument0;
var listsize = ds_list_size(list);

var ascend = (recent_sort_mode = e_recent_sort.date_ascend || recent_sort_mode = e_recent_sort.filename_ascend);
var datesort = (recent_sort_mode = e_recent_sort.date_ascend || recent_sort_mode = e_recent_sort.date_descend);
var datalist = ds_list_create();
var prevlist = ds_list_create();
var newlist = ds_list_create();

if (datesort)
{
	for (var i = 0; i < listsize; i++)
		ds_list_add(datalist, list[|i].last_opened)
	
	ds_list_sort(datalist, ascend)
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
		ds_list_add(datalist, string_lower(filename_name(list[|i].filename)))
	
	ds_list_sort(datalist, !ascend)
	ds_list_copy(prevlist, list)
	
	// Look for sorted values and fill list
	for (var i = 0; i < listsize; i++)
	{
		for (var j = 0; j < ds_list_size(prevlist); j++)
		{
			if (datalist[|i] = string_lower(filename_name(list[|i].filename)))
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