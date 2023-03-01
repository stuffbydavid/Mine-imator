/// sortlist_add(sortlist, value, index)
/// @arg sortlist
/// @arg value
/// @arg index
/// @desc sortlist_update should be called after.

function sortlist_add(sortlist, value, index = -1)
{
	if (index >= 0)
	{
		ds_list_insert(sortlist.list, index, value)
		ds_list_insert(sortlist.display_list, index, value)
	}
	else
	{
		ds_list_add(sortlist.list, value)
		ds_list_add(sortlist.display_list, value)
	}
}
