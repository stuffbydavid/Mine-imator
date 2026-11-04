/// @desc Reads a decoded JSON map of keys into the destination map.
/// @arg prefix
/// @arg source
/// @arg destination

function language_load_map(prefix, smap, dmap)
{
	if (!ds_map_valid(smap))
		return 0
	
	var key = ds_map_find_first(smap);
	while (!is_undefined(key))
	{
		if (string_contains(key, "/"))
			language_load_map(prefix + key, smap[?key], dmap)
		else
			dmap[?prefix + key] = smap[?key]
		
		key = ds_map_find_next(smap, key)
	}
}
