/// sortlist_add(sortlist, value)
/// @arg sortlist
/// @arg value
/// @desc sortlist_update should be called after.

function sortlist_add(slist, value)
{
	ds_list_add(slist.list, value)
	ds_list_add(slist.display_list, value)
}
