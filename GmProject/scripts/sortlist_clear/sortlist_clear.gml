/// sortlist_clear(sortlist)
/// @arg sortlist
/// @desc Clears the given sortlist.

function sortlist_clear(slist)
{
	slist.select = null
	ds_list_clear(slist.list)
	ds_list_clear(slist.display_list)
	slist.search = false
	slist.column_sort = null
}
