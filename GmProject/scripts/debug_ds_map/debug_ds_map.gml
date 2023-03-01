/// debug_ds_map(map)
/// @arg map

function debug_ds_map(map)
{
	var keylist, key;
	
	keylist = ds_list_create()
	key = ds_map_find_first(map)
	while (!is_undefined(key))
	{
		ds_list_add(keylist, key)
		key = ds_map_find_next(map, key)
	}
	
	ds_list_sort(keylist, true)
	
	debug("Elements", ds_list_size(keylist))
	for (var i = 0; i < ds_list_size(keylist); i++)
		debug("   " + string(keylist[|i]) + " => " + string(map[?keylist[|i]]))
	
	ds_list_destroy(keylist)
}
