/// view_transform_begin(transform_type)
/// @arg transform_type
/// @desc Captures transform targets at the start of a drag.

function view_transform_begin(transform_type)
{
	view_transform_update_selection()
	view_control_transform_type = transform_type
	view_control_transform_mode = view_transform_mode_effective(transform_type)
	view_control_transform_history_started = false
	view_control_transform_start = []
	view_control_transform_parent_inverse = []
	view_control_transform_scale_basis = []
	ds_map_clear(view_control_transform_target_map)

	if (view_control_transform_mode = e_transform_mode.GIMBAL || transform_type = e_value_type.TRANSFORM_ROT)
		return 0

	view_control_transform_basis = setting_transform_mode = e_transform_mode.LOCAL ? view_transform_orientation(tl_edit) : array_copy_1d(MAT_IDENTITY)
	view_control_transform_origin = vec3_mul_matrix(tl_edit.world_pos, matrix_inverse_ext(view_control_transform_basis))

	with (obj_timeline)
	{
		if (!selected || !value_type[other.view_control_transform_type] || view_transform_selected_ancestor(id, other.view_control_transform_type))
			continue

		var index = array_length(other.view_control_transform_start)
		var vid = other.view_control_transform_type = e_value_type.TRANSFORM_POS ? e_value.POS_X : e_value.SCA_X
		other.view_control_transform_start[index] = vec3(value[vid], value[vid + 1], value[vid + 2])
		ds_map_add(other.view_control_transform_target_map, save_id_get(id), index)

		var parent_basis = view_transform_parent_matrix(id)
		if (other.view_control_transform_type = e_value_type.TRANSFORM_POS)
			other.view_control_transform_parent_inverse[index] = inherit_position ? matrix_inverse_ext(parent_basis) : MAT_IDENTITY
		else
		{
			// Normal scaling follows parent axes (R*S*P). Resize scaling follows
			// the object's rotated axes (S*R*P), as in tl_update_matrix.
			other.view_control_transform_scale_basis[index] = (scale_resize || !inherit_scale || type = e_tl_type.PARTICLE_SPAWNER) ? view_transform_orientation(id) : parent_basis
		}
	}

	return 0
}
