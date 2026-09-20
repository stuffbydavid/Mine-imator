/// view_transform_mode_effective(transform_type)
/// @arg transform_type
/// @desc Returns the selected mode, or Gimbal when this tool cannot transform the selection.

function view_transform_mode_effective(transform_type)
{
	var index = transform_type - e_value_type.TRANSFORM_POS;
	if (setting_transform_mode = e_transform_mode.GIMBAL || view_control_transform_key_mixed[index] ||
		(view_control_transform_key_marker[index] != noone && view_control_transform_key_marker[index] != timeline_marker))
		return e_transform_mode.GIMBAL

	for (var i = 0; i < array_length(view_control_transform_selection); i++)
	{
		var timeline = view_control_transform_selection[i];
		if (!instance_exists(timeline) || !timeline.value_type[transform_type])
			continue

		if (timeline.lock || timeline.value[e_value.IK_TARGET] != null || timeline.value[e_value.PATH_OBJ] != null ||
			(timeline.part_of != null && timeline.part_of.inherit_pose))
			return e_transform_mode.GIMBAL

		if (transform_type = e_value_type.TRANSFORM_ROT)
		{
			if (!view_rotation_parent_supported(timeline))
				return e_transform_mode.GIMBAL
		}
		else
		{
			var parent_basis = view_transform_parent_matrix(timeline);
			if (!view_transform_basis_valid(parent_basis, transform_type = e_value_type.TRANSFORM_SCA))
				return e_transform_mode.GIMBAL

			if (transform_type = e_value_type.TRANSFORM_SCA && (!timeline.inherit_rotation ||
				min(abs(timeline.value[e_value.SCA_X]), abs(timeline.value[e_value.SCA_Y]), abs(timeline.value[e_value.SCA_Z])) <= snap_min))
				return e_transform_mode.GIMBAL
		}
	}

	return setting_transform_mode
}
