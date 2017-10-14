/// ds_list_merge(id, source)
/// @arg id
/// @arg source

var list, src;
list = argument0
src = argument1

for (var i = 0; i < ds_list_size(src); i++)
	ds_list_add(list, src[|i])