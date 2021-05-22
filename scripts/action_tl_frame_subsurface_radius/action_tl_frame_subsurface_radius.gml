/// action_tl_frame_subsurface_radius(value, add)
/// @arg value
/// @arg add

function action_tl_frame_subsurface_radius(val, add)
{
	tl_value_set_start(action_tl_frame_subsurface_radius, true)
	tl_value_set(e_value.SUBSURFACE_RADIUS_RED + axis_edit, val / 100, add)
	tl_value_set_done()
}