/// ds_map_merge(id, source, [overwrite])
/// @arg id
/// @arg source
/// @arg [overwrite]

var map, source, overwrite;
map = argument[0]
source = argument[1]
if (argument_count > 2)
	overwrite = argument[2]
else
	overwrite = true

var key = ds_map_find_first(source);
while (!is_undefined(key))
{
	if (overwrite || is_undefined(map[?key]))
		map[?key] = source[?key]
	key = ds_map_find_next(source, key)
}