/// CppSeparate IntType ds_int_map_create()
/// Create a fast hash-table map that will only take integers as keys.
/// This will automatically replace ds_map_create by CppGen if only integers are used as keys in the map.

function ds_int_map_create()
{
	return ds_map_create()
}