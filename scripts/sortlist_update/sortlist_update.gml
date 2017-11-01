/// sortlist_update(sortlist)
/// @arg sortlist
/// @desc Updates the sortlist when sorting or filtering.

var slist = argument0;
ds_list_clear(slist.display_list)

if (slist.column_sort != null)
{
	var sortedlist, valuelist;
	sortedlist = ds_list_create()
	valuelist = ds_list_create()
	ds_list_copy(valuelist, slist.list)
	
	// Store values in column and sort
	for (var p = 0; p < ds_list_size(valuelist); p++)
		ds_list_add(sortedlist, string_lower(sortlist_column_get(slist, valuelist[|p], slist.column_sort)))
	ds_list_sort(sortedlist, !slist.sort_asc)
	
	// Find which values belong to what items
	while (ds_list_size(sortedlist) > 0)
	{
		for (var p = 0; p < ds_list_size(valuelist); p++)
		{
			var val, colval;
			val = valuelist[|p]
			colval = string_lower(sortlist_column_get(slist, val, slist.column_sort))
			if (sortedlist[|0] = colval)
			{
				ds_list_add(slist.display_list, val)
				ds_list_delete(valuelist, p)
				ds_list_delete(sortedlist, 0)
				break
			}
		}
	}
	
	ds_list_destroy(sortedlist)
	ds_list_destroy(valuelist)
}
else
	ds_list_copy(slist.display_list, slist.list)

// Remove non-matched items from list
var check = string_lower(slist.filter_tbx.text);
if (slist.filter && check != "")
{
	for (var p = 0; p < ds_list_size(slist.display_list); p++)
	{
		var val, match;
		val = slist.display_list[|p]
		match = false
		for (var c = 0; c < slist.columns; c++)
		{
			if (string_count(check, string_lower(string(sortlist_column_get(slist, val, c)))) > 0)
			{
				match = true
				break
			}
		}
		
		if (!match)
		{
			ds_list_delete(slist.display_list, p)
			p--
		}
	}
}