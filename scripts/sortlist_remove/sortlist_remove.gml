/// sortlist_remove(sortlist, value)
/// @arg sortlist
/// @arg value
/// @desc Removes the given value from the sortlist

var sl, value, index;
sl = argument0
value = argument1

index = ds_list_find_index(sl.list, value)
if (index < 0)
	return null

ds_list_delete(sl.list, index)
ds_list_delete(sl.filter_list, ds_list_find_index(sl.filter_list, value))

index = min(ds_list_size(sl.list) - 1, index)
if (index < 0)
	return null

return sl.list[|index]