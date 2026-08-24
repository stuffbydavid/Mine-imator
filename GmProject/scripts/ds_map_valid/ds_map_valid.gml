/// CppSeparate BoolType ds_map_valid(IntType)
/// ds_map_valid(id)
/// @arg id

function ds_map_valid(map)
{
	return (is_handle(map) && ds_exists(map, ds_type_map))
}
