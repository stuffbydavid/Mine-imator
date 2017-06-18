/// sortlist_sort(sortlist)
/// @arg sortlist
/// @desc Updates the sortlist.

var slist = argument0;
ds_list_clear(slist.filter_list)

if (slist.column_sort = null) // Sort by value
	ds_list_sort(slist.list, true)
else
{
	var sortedvalues, newlist;
	sortedvalues = ds_list_create()
	newlist = ds_list_create()
	
	// Store values in column and sort
	for (var p = 0; p < ds_list_size(slist.list); p++)
		ds_list_add(sortedvalues, sortlist_column_get(slist, ds_list_find_value(slist.list, p), slist.column_sort))
	ds_list_sort(sortedvalues, !slist.sort_asc)
	
	// Find which values belong to what items
	while (ds_list_size(sortedvalues) > 0)
	{
		for (var p = 0; p < ds_list_size(slist.list); p++)
		{
			var val, colval;
			val = ds_list_find_value(slist.list, p)
			colval = sortlist_column_get(slist, val, slist.column_sort)
			if (ds_list_find_value(sortedvalues, 0) = colval)
			{
				ds_list_add(newlist, val)
				ds_list_delete(slist.list, p)
				ds_list_delete(sortedvalues, 0)
				break
			}
		}
	}
	
	ds_list_destroy(slist.list)
	ds_list_destroy(sortedvalues)
	slist.list = newlist
}

// Add matches to filtered list
var check = string_lower(slist.filter_tbx.text);

for (var p = 0; p < ds_list_size(slist.list); p++)
{
	var val, add;
	val = ds_list_find_value(slist.list, p)
	add = true
	if (check != "")
	{
		add = false
		for (var c = 0; c < slist.columns; c++)
		{
			if (string_count(check, string_lower(string(sortlist_column_get(slist, val, c)))) > 0)
			{
				add = true
				break
			}
		}
	}
	if (add)
		ds_list_add(slist.filter_list, val)
}
