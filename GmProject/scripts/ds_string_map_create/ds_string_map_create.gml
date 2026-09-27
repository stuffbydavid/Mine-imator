/// CppSeparate IntType ds_string_map_create()
/// Create a fast hash-table map that will only take strings as keys.
/// This will automatically replace ds_map_create by CppGen if only strings are used as keys in the map.

function ds_string_map_create()
{
	return ds_map_create()
}