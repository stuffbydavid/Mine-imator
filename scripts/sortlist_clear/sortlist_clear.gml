/// sortlist_clear(sortlist)
/// @arg sortlist
/// @desc Clears the given sortlist.

var slist = argument0;

slist.select = null
ds_list_clear(slist.list)
ds_list_clear(slist.display_list)
slist.filter = false
slist.filter_ani = 0
slist.column_sort = null
slist.sort_desc = true
