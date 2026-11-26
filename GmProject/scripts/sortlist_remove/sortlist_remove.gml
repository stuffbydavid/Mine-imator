/// @desc Removes the given value from the sortlist.
/// @arg sortlist
/// @arg value

function sortlist_remove(slist, value)
{
	var index = ds_list_find_index(slist.list, value);
	if (index < 0)
		return null
	
	ds_list_delete(slist.list, index)
	ds_list_delete(slist.display_list, ds_list_find_index(slist.display_list, value))
	
	index = min(ds_list_size(slist.list) - 1, index)
	if (index < 0)
		return null
	
	return slist.list[|index]
}
