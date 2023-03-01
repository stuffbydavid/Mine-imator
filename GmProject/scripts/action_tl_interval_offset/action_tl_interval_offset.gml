/// action_tl_interval_offset(value, add)
/// @arg value
/// @arg add

function action_tl_interval_offset(val, add)
{
	project_changed = true
	timeline_interval_offset = timeline_interval_offset * add + val
}
