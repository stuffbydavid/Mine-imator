/// language_load_map(prefix, source, destination)
/// @arg prefix
/// @arg source
/// @arg destination
/// @desc Reads a decoded JSON map of keys into the destination map.

var pre, smap, dmap, key;
pre = argument0
smap = argument1
dmap = argument2

if (!ds_exists(smap, ds_type_map))
	return 0

key = ds_map_find_first(smap)
while (!is_undefined(key))
{
	if (string_contains(key, "/"))
		language_load_map(pre + string_replace(key, "/", ""), smap[?key], dmap)
	else
	{
		dmap[?pre + key] = smap[?key]
		log(pre+key, smap[?key])
	}
		
	key = ds_map_find_next(smap, key)
}