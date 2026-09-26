/// tl_value_set_start_targets(script, combine, target_index_map)
/// @arg script
/// @arg combine
/// @arg target_index_map
/// @desc Starts a value edit for the timelines captured by a viewport transform.

function tl_value_set_start_targets(script, combine, target_index_map)
{
	return tl_value_set_start_filtered(script, combine, target_index_map, true)
}
