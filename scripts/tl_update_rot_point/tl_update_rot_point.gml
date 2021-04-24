/// tl_update_rot_point()
/// @desc Updates the rotation point of the given timeline if no custom has been set.

function tl_update_rot_point()
{
	if (temp != null && part_of = null && !rot_point_custom)
		rot_point_render = array_copy_1d(temp.rot_point)
	else
		rot_point_render = array_copy_1d(rot_point)
	
	update_matrix = true
}
