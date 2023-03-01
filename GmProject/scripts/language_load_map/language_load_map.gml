/// language_load_map(prefix, source, destination)
/// @arg prefix
/// @arg source
/// @arg destination
/// @desc Reads a decoded JSON map of keys into the destination map.

function language_load_map(pre, smap, dmap)
{
	var key;
	
	if (!ds_map_valid(smap))
		return 0
	
	key = ds_map_find_first(smap)
	while (!is_undefined(key))
	{
		if (string_contains(key, "/"))
			language_load_map(pre + string_replace(key, "/", ""), smap[?key], dmap)
		else
			dmap[?pre + key] = smap[?key]
		
		key = ds_map_find_next(smap, key)
	}
}
