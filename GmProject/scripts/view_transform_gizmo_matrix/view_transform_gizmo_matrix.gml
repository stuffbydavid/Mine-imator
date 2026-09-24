/// view_transform_gizmo_matrix(transform_type, legacy_matrix)
/// @arg transform_type
/// @arg legacy_matrix
/// @desc Builds the gizmo matrix for a transform type.

function view_transform_gizmo_matrix(transform_type, legacy_matrix)
{
	var dragging = window_busy = "rendercontrol" && view_control_transform_type = transform_type &&
		((view_control_edit >= e_view_control.POS_X && view_control_edit <= e_view_control.POS_PAN) ||
		 (view_control_edit >= e_view_control.SCA_X && view_control_edit <= e_view_control.SCA_XYZ))
	var mode = dragging ? view_control_transform_mode : view_transform_mode_effective(transform_type)
	if (mode = e_transform_mode.GIMBAL)
		return legacy_matrix

	var result
	if (dragging)
		result = array_copy_1d(view_control_transform_basis)
	else
		result = mode = e_transform_mode.LOCAL ? view_transform_orientation(tl_edit) : array_copy_1d(MAT_IDENTITY)

	result[MAT_X] = tl_edit.world_pos[X]
	result[MAT_Y] = tl_edit.world_pos[Y]
	result[MAT_Z] = tl_edit.world_pos[Z]
	return result
}
