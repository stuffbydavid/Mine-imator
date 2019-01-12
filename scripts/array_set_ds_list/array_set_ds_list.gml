/// array_set_ds_list(id)
/// @arg id
/// @desc Converts a ds list to an array and returns it

var list, arr;
list = argument0
arr = array()

for (var i = 0; i < ds_list_size(list); i++)
	array_add(arr, list[|i])

return arr