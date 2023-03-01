/// ds_map_valid(id)
/// @arg id

function ds_map_valid(map)
{
	return (is_real(map) && ds_exists(map, ds_type_map))
}
