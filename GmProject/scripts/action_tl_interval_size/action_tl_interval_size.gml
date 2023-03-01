/// action_tl_interval_size(value, add)
/// @arg value
/// @arg add

function action_tl_interval_size(val, add)
{
	project_changed = true
	timeline_interval_size = timeline_interval_size * add + val
}
