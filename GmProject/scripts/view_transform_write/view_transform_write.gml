/// view_transform_write(values_x, values_y, values_z)
/// @arg values_x
/// @arg values_y
/// @arg values_z
/// @desc Writes captured transform values through one keyframe and undo boundary.

function view_transform_write(values_x, values_y, values_z)
{
	if (array_length(values_x) = 0)
		return 0

	var vid, action;
	switch (view_control_transform_type)
	{
		case e_value_type.TRANSFORM_POS:
			vid = e_value.POS_X
			action = action_tl_frame_pos_xyz
			break

		case e_value_type.TRANSFORM_ROT:
			vid = e_value.ROT_X
			action = action_tl_frame_rot_xyz
			break

		case e_value_type.TRANSFORM_SCA:
			vid = e_value.SCA_X
			action = action_tl_frame_scale_xyz
			break
	}

	tl_value_set_start_targets(action, view_control_transform_history_started, view_control_transform_target_map)
	view_control_transform_history_started = true

	tl_value_set_target_values(vid, view_control_transform_target_map, values_x)
	tl_value_set_target_values(vid + 1, view_control_transform_target_map, values_y)
	tl_value_set_target_values(vid + 2, view_control_transform_target_map, values_z)
	tl_value_set_done()
	return 0
}
