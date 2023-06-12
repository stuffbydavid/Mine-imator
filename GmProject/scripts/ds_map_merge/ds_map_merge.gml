/// ds_map_merge(id, source, [overwrite])
/// @arg id
/// @arg source
/// @arg [overwrite]

function ds_map_merge(map, source, overwrite = true)
{
	var key = ds_map_find_first(source);
	while (!is_undefined(key))
	{
		if (overwrite || is_undefined(map[?key]))
			map[?key] = source[?key]
		key = ds_map_find_next(source, key)
	}
}
